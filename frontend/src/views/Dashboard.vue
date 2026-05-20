<template>
  <div class="dashboard">
    <!-- 概览卡片 -->
    <el-row :gutter="20" class="summary-row">
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="summary-card income-card">
          <div class="card-icon"><el-icon :size="28"><TrendCharts /></el-icon></div>
          <div class="card-info">
            <p class="card-label">本月收入</p>
            <p class="card-value">¥ {{ summary.monthIncome }}</p>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="summary-card expense-card">
          <div class="card-icon"><el-icon :size="28"><Money /></el-icon></div>
          <div class="card-info">
            <p class="card-label">本月支出</p>
            <p class="card-value">¥ {{ summary.monthExpense }}</p>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="summary-card balance-card">
          <div class="card-icon"><el-icon :size="28"><Wallet /></el-icon></div>
          <div class="card-info">
            <p class="card-label">本月结余</p>
            <p class="card-value">¥ {{ summary.monthBalance }}</p>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="summary-card count-card">
          <div class="card-icon"><el-icon :size="28"><Document /></el-icon></div>
          <div class="card-info">
            <p class="card-label">本月记录</p>
            <p class="card-value">{{ summary.monthCount }} 条</p>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 图表区 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :xs="24" :lg="14">
        <el-card shadow="hover">
          <template #header><span class="card-title">近6个月收支趋势</span></template>
          <div ref="trendChartRef" class="chart-box"></div>
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="10">
        <el-card shadow="hover">
          <template #header><span class="card-title">本月支出分类</span></template>
          <div ref="pieChartRef" class="chart-box"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 最近记录 -->
    <el-card shadow="hover" class="recent-card">
      <template #header>
        <div class="card-header">
          <span class="card-title">最近记录</span>
          <el-button text type="primary" @click="$router.push('/expense')">查看全部</el-button>
        </div>
      </template>
      <el-table :data="recentRecords" stripe size="small" style="width: 100%">
        <el-table-column prop="recordDate" label="日期" width="120" />
        <el-table-column label="类型" width="80">
          <template #default="{ row }">
            <el-tag :type="row.type === 'INCOME' ? 'success' : 'danger'" size="small">
              {{ row.type === 'INCOME' ? '收入' : '支出' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="categoryName" label="分类" width="100" />
        <el-table-column prop="amount" label="金额" width="120">
          <template #default="{ row }">
            <span :class="row.type === 'INCOME' ? 'income-text' : 'expense-text'">
              {{ row.type === 'INCOME' ? '+' : '-' }}¥{{ row.amount }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" min-width="180" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onBeforeUnmount, nextTick } from 'vue'
import * as echarts from 'echarts'
import { recordApi } from '@/api/record'
import { categoryApi } from '@/api/category'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()

const trendChartRef = ref(null)
const pieChartRef = ref(null)
let trendChart = null
let pieChart = null

const summary = reactive({
  monthIncome: '0.00',
  monthExpense: '0.00',
  monthBalance: '0.00',
  monthCount: 0
})

const recentRecords = ref([])

function formatNum(n) {
  return Number(n || 0).toFixed(2)
}

function renderTrendChart(months, incomeData, expenseData) {
  if (!trendChartRef.value) return
  const colors = ['#67C23A', '#F56C6C']
  trendChart = echarts.init(trendChartRef.value)
  trendChart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['收入', '支出'], bottom: 0 },
    grid: { left: 20, right: 20, bottom: 30, top: 20, containLabel: true },
    xAxis: { type: 'category', data: months, axisLabel: { rotate: 30 } },
    yAxis: { type: 'value' },
    series: [
      {
        name: '收入', type: 'bar', data: incomeData,
        itemStyle: { color: colors[0], borderRadius: [4, 4, 0, 0] },
        barMaxWidth: 40
      },
      {
        name: '支出', type: 'bar', data: expenseData,
        itemStyle: { color: colors[1], borderRadius: [4, 4, 0, 0] },
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
    series: [{
      type: 'pie',
      radius: ['50%', '75%'],
      center: ['50%', '50%'],
      itemStyle: { borderRadius: 4, borderColor: '#fff', borderWidth: 2 },
      label: { formatter: '{b}\n{d}%' },
      data,
      emphasis: {
        label: { fontSize: 16, fontWeight: 'bold' }
      }
    }]
  })
}

async function loadData() {
  try {
    const now = new Date()
    // 获取近6个月的起始日期
    const sixMonthsAgo = new Date(now.getFullYear(), now.getMonth() - 5, 1)
    const trendStartDate = `${sixMonthsAgo.getFullYear()}-${String(sixMonthsAgo.getMonth() + 1).padStart(2, '0')}-01`
    const thisMonthStart = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-01`

    const [recordRes, categoryRes] = await Promise.all([
      recordApi.list({ userId: auth.user.id, startDate: trendStartDate }),
      categoryApi.list()
    ])
    const records = recordRes?.data || []
    const categories = categoryRes?.data || []
    const catMap = {}
    categories.forEach(c => { catMap[c.id] = c.name })

    // 附上分类名
    const enriched = records.map(r => ({
      ...r,
      categoryName: catMap[r.categoryId] || '未分类'
    }))

    // 本月汇总（仅本月记录）
    const thisMonthRecords = enriched.filter(r => r.recordDate && r.recordDate >= thisMonthStart)
    let income = 0, expense = 0
    const expenseByCat = {}
    thisMonthRecords.forEach(r => {
      const amt = parseFloat(r.amount) || 0
      if (r.type === 'INCOME') income += amt
      else {
        expense += amt
        const catName = r.categoryName
        expenseByCat[catName] = (expenseByCat[catName] || 0) + amt
      }
    })
    summary.monthIncome = formatNum(income)
    summary.monthExpense = formatNum(expense)
    summary.monthBalance = formatNum(income - expense)
    summary.monthCount = thisMonthRecords.length
    recentRecords.value = enriched.slice(0, 6)

    // 饼图
    const pieData = Object.entries(expenseByCat).map(([name, value]) => ({
      name, value: Math.round(value * 100) / 100
    }))
    renderPieChart(pieData.length > 0 ? pieData : [{ name: '暂无数据', value: 1 }])

    // 近6个月趋势（用真实数据）
    buildMonthlyTrend(enriched, sixMonthsAgo)
  } catch {
    summary.monthIncome = '0.00'
    summary.monthExpense = '0.00'
    summary.monthBalance = '0.00'
    summary.monthCount = 0
    recentRecords.value = []
    renderPieChart([{ name: '暂无数据', value: 1 }])
    renderTrendChart([], [], [])
  }
}

function buildMonthlyTrend(records, fromDate) {
  const months = []
  const incomeD = []
  const expenseD = []
  const cursor = new Date(fromDate)
  const now = new Date()
  while (cursor <= now) {
    const key = `${cursor.getFullYear()}-${String(cursor.getMonth() + 1).padStart(2, '0')}`
    months.push(key)
    incomeD.push(0)
    expenseD.push(0)
    cursor.setMonth(cursor.getMonth() + 1)
  }
  records.forEach(r => {
    if (!r.recordDate) return
    const key = r.recordDate.substring(0, 7)
    const idx = months.indexOf(key)
    if (idx === -1) return
    const amt = parseFloat(r.amount) || 0
    if (r.type === 'INCOME') incomeD[idx] += amt
    else expenseD[idx] += amt
  })
  renderTrendChart(months, incomeD, expenseD)
}

onMounted(async () => {
  await nextTick()
  await loadData()
})

onBeforeUnmount(() => {
  trendChart?.dispose()
  pieChart?.dispose()
})

// handle resize
window.addEventListener('resize', () => {
  trendChart?.resize()
  pieChart?.resize()
})
</script>

<style scoped>
.dashboard {
  padding: 4px;
}
.summary-row {
  margin-bottom: 20px;
}
.summary-card {
  border-radius: 10px;
}
.summary-card :deep(.el-card__body) {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
}
.card-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
}
.income-card .card-icon { background: linear-gradient(135deg, #67C23A, #85CE61); }
.expense-card .card-icon { background: linear-gradient(135deg, #F56C6C, #F89898); }
.balance-card .card-icon { background: linear-gradient(135deg, #409EFF, #66B1FF); }
.count-card .card-icon { background: linear-gradient(135deg, #E6A23C, #EBB563); }
.card-label {
  margin: 0;
  font-size: 13px;
  color: #909399;
}
.card-value {
  margin: 6px 0 0;
  font-size: 22px;
  font-weight: 700;
  color: #303133;
}
.chart-row {
  margin-bottom: 20px;
}
.chart-box {
  height: 320px;
}
.recent-card {
  border-radius: 10px;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.card-title {
  font-weight: 600;
  color: #303133;
}
.income-text {
  color: #67C23A;
  font-weight: 600;
}
.expense-text {
  color: #F56C6C;
  font-weight: 600;
}
</style>
