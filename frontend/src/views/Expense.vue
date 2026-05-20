<template>
  <div class="record-page">
    <!-- 筛选栏 -->
    <el-card shadow="never" class="filter-card">
      <el-form :inline="true" :model="filter" size="default">
        <el-form-item label="日期范围">
          <el-date-picker
            v-model="filter.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
            style="width: 260px"
          />
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="filter.categoryId" placeholder="全部分类" clearable style="width: 160px">
            <el-option
              v-for="c in categories"
              :key="c.id"
              :label="c.name"
              :value="c.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchData">查询</el-button>
          <el-button @click="resetFilter">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 操作栏 -->
    <el-card shadow="never" class="table-card">
      <div class="table-header">
        <span class="table-title">支出记录</span>
        <el-button type="danger" size="default" @click="openDialog()">
          <el-icon><Plus /></el-icon> 记一笔支出
        </el-button>
      </div>

      <!-- 表格 -->
      <el-table :data="tableData" stripe style="width: 100%" v-loading="loading">
        <el-table-column prop="recordDate" label="日期" width="120" />
        <el-table-column label="分类" width="140">
          <template #default="{ row }">
            <el-tag
              v-if="row.categoryName"
              :color="catMap[row.categoryId]?.color"
              effect="dark"
              size="small"
            >
              {{ row.categoryName }}
            </el-tag>
            <span v-else class="text-gray">未分类</span>
          </template>
        </el-table-column>
        <el-table-column prop="amount" label="金额" width="150">
          <template #default="{ row }">
            <span class="expense-text">-¥{{ row.amount }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" min-width="200" show-overflow-tooltip />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button text type="primary" size="small" @click="openDialog(row)">编辑</el-button>
            <el-button text type="danger" size="small" @click="handleDelete(row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="pagination.current"
          v-model:page-size="pagination.size"
          :total="pagination.total"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="fetchData"
          @current-change="fetchData"
        />
      </div>
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑支出' : '记一笔支出'"
      width="480px"
      destroy-on-close
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="日期" prop="recordDate">
          <el-date-picker v-model="form.recordDate" type="date" value-format="YYYY-MM-DD" style="width: 100%" />
        </el-form-item>
        <el-form-item label="分类" prop="categoryId">
          <el-select v-model="form.categoryId" placeholder="请选择分类" style="width: 100%">
            <el-option v-for="c in categories" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="金额" prop="amount">
          <el-input-number v-model="form.amount" :min="0.01" :precision="2" style="width: 100%" placeholder="请输入金额" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" placeholder="请输入描述" maxlength="200" show-word-limit />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { recordApi } from '@/api/record'
import { categoryApi } from '@/api/category'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()

const loading = ref(false)
const saving = ref(false)
const dialogVisible = ref(false)
const isEdit = ref(false)
const formRef = ref(null)
const tableData = ref([])
const categories = ref([])

const catMap = computed(() => {
  const m = {}
  categories.value.forEach(c => { m[c.id] = c })
  return m
})

const filter = reactive({
  dateRange: null,
  categoryId: null
})

const form = reactive({
  id: null,
  recordDate: '',
  categoryId: null,
  amount: null,
  description: ''
})

const rules = {
  recordDate: [{ required: true, message: '请选择日期', trigger: 'change' }],
  categoryId: [{ required: true, message: '请选择分类', trigger: 'change' }],
  amount: [{ required: true, message: '请输入金额', trigger: 'blur' }]
}

const pagination = reactive({
  current: 1,
  size: 10,
  total: 0
})

const RECORD_TYPE = 'EXPENSE'

async function loadCategories() {
  try {
    const res = await categoryApi.list(RECORD_TYPE)
    categories.value = res?.data || []
  } catch { /* mock later */ }
}

async function fetchData() {
  loading.value = true
  try {
    const params = {
      userId: auth.user.id,
      type: RECORD_TYPE,
      categoryId: filter.categoryId || undefined
    }
    if (filter.dateRange && filter.dateRange.length === 2) {
      params.startDate = filter.dateRange[0]
      params.endDate = filter.dateRange[1]
    }
    const res = await recordApi.list(params)
    tableData.value = (res?.data || []).map(r => ({
      ...r,
      categoryName: catMap.value[r.categoryId]?.name || ''
    }))
    pagination.total = tableData.value.length
  } catch {
    ElMessage.error('加载失败，请确认后端已启动')
    tableData.value = []
    pagination.total = 0
  } finally {
    loading.value = false
  }
}

function resetFilter() {
  filter.dateRange = null
  filter.categoryId = null
  pagination.current = 1
  fetchData()
}

function openDialog(row) {
  if (row) {
    isEdit.value = true
    form.id = row.id
    form.recordDate = row.recordDate
    form.categoryId = row.categoryId
    form.amount = parseFloat(row.amount)
    form.description = row.description
  } else {
    isEdit.value = false
    form.id = null
    form.recordDate = new Date().toISOString().slice(0, 10)
    form.categoryId = categories.value[0]?.id || null
    form.amount = null
    form.description = ''
  }
  dialogVisible.value = true
}

async function handleSave() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  saving.value = true
  try {
    const data = {
      userId: auth.user.id,
      type: RECORD_TYPE,
      recordDate: form.recordDate,
      categoryId: form.categoryId,
      amount: form.amount,
      description: form.description
    }
    if (isEdit.value) {
      await recordApi.update(form.id, data)
      ElMessage.success('更新成功')
    } else {
      await recordApi.create(data)
      ElMessage.success('添加成功')
    }
    dialogVisible.value = false
    fetchData()
  } catch {
    ElMessage.warning('操作失败，请确认后端已启动')
  } finally {
    saving.value = false
  }
}

async function handleDelete(id) {
  await ElMessageBox.confirm('确定要删除这条记录吗？', '提示', { type: 'warning' })
  try {
    await recordApi.remove(id)
    ElMessage.success('删除成功')
    fetchData()
  } catch { /* cancel or error */ }
}

onMounted(async () => {
  await loadCategories()
  fetchData()
})
</script>

<style scoped>
.record-page {
  padding: 4px;
}
.filter-card {
  margin-bottom: 16px;
  border-radius: 10px;
}
.filter-card :deep(.el-card__body) {
  padding: 16px 20px 0;
}
.table-card {
  border-radius: 10px;
}
.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}
.table-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}
.pagination-wrap {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}
.expense-text {
  color: #F56C6C;
  font-weight: 600;
}
.text-gray {
  color: #909399;
}
</style>
