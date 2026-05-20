<template>
  <div class="categories-page">
    <!-- 支出分类 -->
    <el-card shadow="never" class="cat-card">
      <template #header>
        <div class="card-bar">
          <span class="card-bar-title">
            <el-tag type="danger" size="small">支出</el-tag>
            支出分类
          </span>
          <el-button type="primary" size="small" @click="openDialog('EXPENSE')">
            <el-icon><Plus /></el-icon> 添加分类
          </el-button>
        </div>
      </template>
      <el-row :gutter="12">
        <el-col v-for="c in expenseCategories" :key="c.id" :xs="12" :sm="8" :md="4">
          <div class="cat-item" @click="openDialog('EXPENSE', c)">
            <div class="cat-icon" :style="{ background: c.color || '#909399' }">
              <el-icon :size="18"><component :is="c.icon || 'More'" /></el-icon>
            </div>
            <span class="cat-name">{{ c.name }}</span>
            <div class="cat-actions" @click.stop>
              <el-button text size="small" type="danger" @click="handleDelete(c.id)">删除</el-button>
            </div>
          </div>
        </el-col>
      </el-row>
      <el-empty v-if="expenseCategories.length === 0" description="暂无支出分类" :image-size="60" />
    </el-card>

    <!-- 收入分类 -->
    <el-card shadow="never" class="cat-card">
      <template #header>
        <div class="card-bar">
          <span class="card-bar-title">
            <el-tag type="success" size="small">收入</el-tag>
            收入分类
          </span>
          <el-button type="success" size="small" @click="openDialog('INCOME')">
            <el-icon><Plus /></el-icon> 添加分类
          </el-button>
        </div>
      </template>
      <el-row :gutter="12">
        <el-col v-for="c in incomeCategories" :key="c.id" :xs="12" :sm="8" :md="4">
          <div class="cat-item" @click="openDialog('INCOME', c)">
            <div class="cat-icon" :style="{ background: c.color || '#909399' }">
              <el-icon :size="18"><component :is="c.icon || 'More'" /></el-icon>
            </div>
            <span class="cat-name">{{ c.name }}</span>
            <div class="cat-actions" @click.stop>
              <el-button text size="small" type="danger" @click="handleDelete(c.id)">删除</el-button>
            </div>
          </div>
        </el-col>
      </el-row>
      <el-empty v-if="incomeCategories.length === 0" description="暂无收入分类" :image-size="60" />
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑分类' : '添加分类'"
      width="460px"
      destroy-on-close
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="名称" prop="name">
          <el-input v-model="form.name" placeholder="分类名称" maxlength="10" />
        </el-form-item>
        <el-form-item label="类型" prop="type">
          <el-radio-group v-model="form.type" :disabled="isEdit">
            <el-radio value="EXPENSE">支出</el-radio>
            <el-radio value="INCOME">收入</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="颜色">
          <el-color-picker v-model="form.color" show-alpha />
        </el-form-item>
        <el-form-item label="图标">
          <el-select v-model="form.icon" placeholder="选择图标">
            <el-option v-for="icon in iconList" :key="icon" :label="icon" :value="icon">
              <el-icon style="margin-right: 6px"><component :is="icon" /></el-icon>
              <span>{{ icon }}</span>
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.sortOrder" :min="0" style="width: 120px" />
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
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { categoryApi } from '@/api/category'

const expenseCategories = ref([])
const incomeCategories = ref([])
const dialogVisible = ref(false)
const isEdit = ref(false)
const formRef = ref(null)
const saving = ref(false)

const iconList = [
  'Food', 'Van', 'ShoppingCart', 'House', 'Film', 'FirstAidKit', 'Reading',
  'Phone', 'Present', 'Money', 'TrendCharts', 'Trophy', 'AlarmClock', 'More',
  'Briefcase', 'CreditCard', 'Wallet', 'Coffee'
]

const form = reactive({
  id: null,
  name: '',
  type: 'EXPENSE',
  color: '#409EFF',
  icon: 'More',
  sortOrder: 0
})

const rules = {
  name: [{ required: true, message: '请输入分类名称', trigger: 'blur' }],
  type: [{ required: true, message: '请选择类型', trigger: 'change' }]
}

async function loadCategories() {
  try {
    const [expRes, incRes] = await Promise.all([
      categoryApi.list('EXPENSE'),
      categoryApi.list('INCOME')
    ])
    expenseCategories.value = expRes?.data || []
    incomeCategories.value = incRes?.data || []
  } catch {
    expenseCategories.value = getMockExpense()
    incomeCategories.value = getMockIncome()
  }
}

function getMockExpense() {
  return [
    { id: 1, name: '餐饮', type: 'EXPENSE', icon: 'Food', color: '#E74C3C', sortOrder: 1 },
    { id: 2, name: '交通', type: 'EXPENSE', icon: 'Van', color: '#F39C12', sortOrder: 2 },
    { id: 3, name: '购物', type: 'EXPENSE', icon: 'ShoppingCart', color: '#E91E63', sortOrder: 3 },
    { id: 4, name: '住房', type: 'EXPENSE', icon: 'House', color: '#9B59B6', sortOrder: 4 },
    { id: 5, name: '娱乐', type: 'EXPENSE', icon: 'Film', color: '#3498DB', sortOrder: 5 },
    { id: 6, name: '医疗', type: 'EXPENSE', icon: 'FirstAidKit', color: '#1ABC9C', sortOrder: 6 },
  ]
}

function getMockIncome() {
  return [
    { id: 11, name: '工资', type: 'INCOME', icon: 'Briefcase', color: '#27AE60', sortOrder: 1 },
    { id: 12, name: '奖金', type: 'INCOME', icon: 'Trophy', color: '#2ECC71', sortOrder: 2 },
    { id: 13, name: '投资收益', type: 'INCOME', icon: 'TrendCharts', color: '#16A085', sortOrder: 3 },
    { id: 14, name: '兼职', type: 'INCOME', icon: 'AlarmClock', color: '#3498DB', sortOrder: 4 },
  ]
}

function openDialog(type = 'EXPENSE', row) {
  if (row) {
    isEdit.value = true
    form.id = row.id
    form.name = row.name
    form.type = row.type
    form.color = row.color || '#409EFF'
    form.icon = row.icon || 'More'
    form.sortOrder = row.sortOrder || 0
  } else {
    isEdit.value = false
    form.id = null
    form.name = ''
    form.type = type
    form.color = type === 'EXPENSE' ? '#F56C6C' : '#67C23A'
    form.icon = 'More'
    form.sortOrder = 0
  }
  dialogVisible.value = true
}

async function handleSave() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  saving.value = true
  try {
    const data = {
      name: form.name,
      type: form.type,
      icon: form.icon,
      color: form.color,
      sortOrder: form.sortOrder
    }
    if (isEdit.value) {
      await categoryApi.update(form.id, data)
      ElMessage.success('更新成功')
    } else {
      await categoryApi.create(data)
      ElMessage.success('添加成功')
    }
    dialogVisible.value = false
    loadCategories()
  } catch {
    ElMessage.warning('操作失败，请确认后端已启动')
  } finally {
    saving.value = false
  }
}

async function handleDelete(id) {
  await ElMessageBox.confirm('确定要删除该分类吗？关联的记录将变为未分类。', '提示', { type: 'warning' })
  try {
    await categoryApi.remove(id)
    ElMessage.success('删除成功')
    loadCategories()
  } catch { /* cancel or error */ }
}

onMounted(() => {
  loadCategories()
})
</script>

<style scoped>
.categories-page {
  padding: 4px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}
.cat-card {
  border-radius: 10px;
}
.card-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.card-bar-title {
  font-weight: 600;
  color: #303133;
  display: flex;
  align-items: center;
  gap: 8px;
}
.cat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 16px 8px 12px;
  margin-bottom: 12px;
  border-radius: 10px;
  border: 1px solid #ebeef5;
  cursor: pointer;
  transition: all 0.2s;
  position: relative;
}
.cat-item:hover {
  border-color: #409eff;
  box-shadow: 0 2px 8px rgba(64,158,255,0.15);
}
.cat-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  margin-bottom: 8px;
}
.cat-name {
  font-size: 13px;
  color: #333;
  margin-bottom: 4px;
}
.cat-actions {
  opacity: 0;
  transition: opacity 0.2s;
}
.cat-item:hover .cat-actions {
  opacity: 1;
}
</style>
