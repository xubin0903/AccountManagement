import request from './request'

export const categoryApi = {
  list(type) {
    const params = type ? { type } : {}
    return request.get('/categories', { params })
  },
  getById(id) {
    return request.get(`/categories/${id}`)
  },
  create(data) {
    return request.post('/categories', data)
  },
  update(id, data) {
    return request.put(`/categories/${id}`, data)
  },
  remove(id) {
    return request.delete(`/categories/${id}`)
  }
}
