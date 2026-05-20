import axios from 'axios'

const apiBaseUrl = import.meta.env.VITE_API_BASE_URL || '/api'

const request = axios.create({
  baseURL: apiBaseUrl,
  timeout: 10000
})

request.interceptors.request.use(
  (config) => config,
  (error) => Promise.reject(error)
)

request.interceptors.response.use(
  (response) => response.data,
  (error) => {
    console.error('请求异常:', error)
    return Promise.reject(error)
  }
)

export default request
