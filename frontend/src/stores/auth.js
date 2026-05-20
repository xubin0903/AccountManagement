import { defineStore } from 'pinia'
import { ref } from 'vue'
import { userApi } from '@/api/user'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(JSON.parse(localStorage.getItem('user') || 'null'))
  const token = ref(localStorage.getItem('token') || '')

  const userId = () => user.value?.id || null

  function setUser(u) {
    user.value = u
    if (u) localStorage.setItem('user', JSON.stringify(u))
    else localStorage.removeItem('user')
  }

  function setToken(t) {
    token.value = t
    if (t) localStorage.setItem('token', t)
    else localStorage.removeItem('token')
  }

  async function login(username, password) {
    const res = await userApi.login({ username, password })
    if (res.code === 200) {
      setToken(res.data.token || 'mock-token')
      setUser(res.data)
      return true
    }
    return false
  }

  async function register(username, password, nickname) {
    const res = await userApi.register({ username, password, nickname })
    return res.code === 200
  }

  function logout() {
    user.value = null
    token.value = ''
    localStorage.removeItem('user')
    localStorage.removeItem('token')
  }

  return { user, token, userId, login, logout, register, setUser, setToken }
})
