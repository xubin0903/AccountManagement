<template>
  <div class="statistics-page">
    <!-- 日期筛选 -->
    <el-card shadow="never" class="filter-bar">
      <el-form :inline="true" size="default">
        <el-form-item label="时间范围">
          <el-date-picker
            v-model="dateRange"
            type="monthrange"
            range-separator="至"
            start-placeholder="开始月份"
            end-placeholder="结束月份"
            value-format="YYYY-MM"
            @change="loadCharts"
          />
        </el-form-item>
        <el-form-item>
          <el-radio-group v-model="viewMode" @change="loadCharts">
            <el-radio-button value="month">按月</el-radio-button>
            <el-radio-button value="year">按年</el-radio-button>
          </el-radio-group>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 收支对比柱状图 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :xs="24" :lg="14">
        <el-card shadow="hover" class="chart-card">
          <template #header><span class="chart-title">收支对比</span></template>
          <div ref="barChartRef" class="chart-box-large"></div>
        </el-card>
      </el-col>

      <!-- 分类占比饼图 -->
      <el-col :xs="24" :lg="10">
        <el-card shadow="hover" class="chart-card">
          <template #header><span class="chart-title">支出分类占比</span></template>
          <div ref="pieChartRef" class="chart-box-large"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 本月每日趋势 -->
    <el-card shadow="hover" class="chart-card" style="margin-top: 20px">
      <template #header><span class="chart-title">本月每日收支趋势</span></template>
      <div ref="lineChartRef" class="chart-box-wide"></div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, nextTick } from 'vue'
import * as echarts from 'echarts'
import { recordApi } from '@/api/record'
import { categoryApi } from '@/api/category'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()

const dateRange = ref([])
const viewMode = ref('month')

const barChartRef = ref(null)
const pieChartRef = ref(null)
const lineChartRef = ref(null)

let barChart = null
let pieChart = null
let lineChart = null

const colors = {
  income: '#67C23A',
  expense: '#F56C6C',
  pieColors: ['#E74C3C', '#F39C12', '#E91E63', '#9B59B6', '#3498DB',
              '#1ABC9C', '#2ECC71', '#607D8B', '#E67E22', '#95A5A6']
}

function renderBarChart(months, incomeData, expenseData) {
  if (!barChartRef.value) return
  barChart = echarts.init(barChartRef.value)
  barChart.setOption({
    tooltip: {
      trigger: 'axis',
      axisPointer: { type: 'shadow' },
      formatter: (params) => {
        const p = params.map(i => `${i.marker} ${i.seriesName}: ¥${i.value}`).join('<br/>')
        return `<b>${params[0].axisValue}</b><br/>${p}`
      }
    },
    legend: { data: ['收入', '支出'], bottom: 0, textStyle: { fontSize: 13 } },
    grid: { left: 20, right: 20, bottom: 35, top: 30, containLabel: true },
    xAxis: { type: 'category', data: months, axisLabel: { rotate: viewMode.value === 'year' ? 0 : 30 } },
    yAxis: { type: 'value', axisLabel: { formatter: '¥{value}' } },
    series: [
      {
        name: '收入', type: 'bar', data: incomeData,
        itemStyle: { color: colors.income, borderRadius: [4, 4, 0, 0] },
        barMaxWidth: 40, barGap: '20%'
      },
      {
        name: '支出', type: 'bar', data: expenseData,
        itemStyle: { color: colors.expense, borderRadius: [4, 4, 0, 0] },
        barMaxWidth: 40
      }
    ]
  })
}

function renderPieChart(data) {
  if (!pieChartRef.value) return
  pieChart = echarts.init(pieChartRef.value)
  pieChart.setOption({
    tooltip: { trigger: 'item', formatter: '{b}: ¥{c} ({d}%)' },
    legend: { type: 'scroll', orient: 'vertical', right: 10, top: 20, bottom: 20 },
    series: [{
      name: '支出分类',
      type: 'pie',
      radius: ['45%', '72%'],
      center: ['42%', '52%'],
      itemStyle: { borderRadius: 4, borderColor: '#fff', borderWidth: 2 },
      label: { show: false },
      emphasis: {
        label: { show: true, fontSize: 16, fontWeight: 'bold' },
        itemStyle: { shadowBlur: 10, shadowOffsetX: 0, shadowColor: 'rgba(0,0,0,0.3)' }
      },
      data
    }]
  })
}

function renderLineChart(records) {
  if (!lineChartRef.value) return
  const now = new Date()
  const dayCount = new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate()
  const days = []
  const incomeData = new Array(dayCount).fill(0)
  const expenseData = new Array(dayCount).fill(0)
  const thisMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`

  for (let d = 1; d <= dayCount; d++) days.push(`${d}日`)

  if (records && records.length) {
    records.forEach(r => {
      if (!r.recordDate || !r.recordDate.startsWith(thisMonth)) return
      const day = parseInt(r.recordDate.split('-')[2]) - 1
      if (r.type === 'INCOME') incomeData[day] += parseFloat(r.amount) || 0
      else expenseData[day] += parseFloat(r.amount) || 0
    })
  }

  lineChart = echarts.init(lineChartRef.value)
  lineChart.setOption({
    tooltip: {
      trigger: 'axis',
      formatter: (params) => {
        const p = params.map(i => `${i.marker} ${i.seriesName}: ¥${i.value}`).join('<br/>')
        return `<b>${params[0].axisValue}</b><br/>${p}`
      }
    },
    legend: { data: ['收入', '支出'], bottom: 0 },
    grid: { left: 20, right: 30, bottom: 35, top: 30, containLabel: true },
    xAxis: {
      type: 'category',
      data: days,
      boundaryGap: false,
      axisLabel: { interval: 3 }
    },
    yAxis: { type: 'value', axisLabel: { formatter: '¥{value}' } },
    series: [
      {
        name: '收入', type: 'line', data: incomeData,
        smooth: true, symbol: 'circle', symbolSize: 4,
        itemStyle: { color: colors.income },
        areaStyle: { color: 'rgba(103,194,58,0.1)' }
      },
      {
        name: '支出', type: 'line', data: expenseData,
        smooth: true, symbol: 'circle', symbolSize: 4,
        itemStyle: { color: colors.expense },
        areaStyle: { color: 'rgba(245,108,108,0.1)' }
      }
    ]
  })
}

async function loadCharts() {
  const now = new Date()
  const y = now.getFullYear()

  try {
    const [recordRes, categoryRes] = await Promise.all([
      recordApi.list({ userId: auth.user.id }),
      categoryApi.list()
    ])
    const records = recordRes?.data || []
    const categories = categoryRes?.data || []
    const catMap = {}
    categories.forEach(c => { catMap[c.id] = c })

    if (viewMode.value === 'month') {
      const months = ['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月']
      const incomeData = new Array(12).fill(0)
      const expenseData = new Array(12).fill(0)
      records.forEach(r => {
        if (!r.recordDate) return
        const m = parseInt(r.recordDate.split('-')[1]) - 1
        if (r.type === 'INCOME') incomeData[m] += parseFloat(r.amount) || 0
        else expenseData[m] += parseFloat(r.amount) || 0
      })
      renderBarChart(months, incomeData, expenseData)
    } else {
      const years = []
      for (let i = 3; i >= 0; i--) years.push(String(y - i))
      const incomeData = new Array(4).fill(0)
      const expenseData = new Array(4).fill(0)
      records.forEach(r => {
        if (!r.recordDate) return
        const ry = r.recordDate.substring(0, 4)
        const idx = years.indexOf(ry)
        if (idx >= 0) {
          if (r.type === 'INCOME') incomeData[idx] += parseFloat(r.amount) || 0
          else expenseData[idx] += parseFloat(r.amount) || 0
        }
      })
      renderBarChart(years, incomeData, expenseData)
    }

    const expenseByCat = {}
    records.forEach(r => {
      if (r.type === 'EXPENSE' && r.recordDate) {
        const name = catMap[r.categoryId]?.name || '未分类'
        expenseByCat[name] = (expenseByCat[name] || 0) + (parseFloat(r.amount) || 0)
      }
    })
    const pieData = Object.entries(expenseByCat).map(([name, value]) => ({ name, value }))
    renderPieChart(pieData.length > 0 ? pieData : [{ name: '暂无数据', value: 1 }])

    renderLineChart(records)
  } catch {
    const months = ['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月']
    renderBarChart(months, new Array(12).fill(0), new Array(12).fill(0))
    renderPieChart([{ name: '暂无数据', value: 1 }])
    renderLineChart([])
  }
}

onMounted(async () => {
  await nextTick()
  loadCharts()
})

onBeforeUnmount(() => {
  barChart?.dispose()
  pieChart?.dispose()
  lineChart?.dispose()
})

window.addEventListener('resize', () => {
  barChart?.resize()
  pieChart?.resize()
  lineChart?.resize()
})
</script>

<style scoped>
.statistics-page {
  padding: 4px;
}
.filter-bar {
  margin-bottom: 20px;
  border-radius: 10px;
}
.filter-bar :deep(.el-card__body) {
  padding: 12px 20px;
}
.chart-row {
  margin-bottom: 0;
}
.chart-card {
  border-radius: 10px;
  margin-bottom: 0;
}
.chart-title {
  font-weight: 600;
  color: #303133;
}
.chart-box-large {
  height: 380px;
}
.chart-box-wide {
  height: 340px;
}
</style>
