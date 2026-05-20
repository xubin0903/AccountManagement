import request from './request'

export const recordApi = {
  list(params) {
    return request.get('/records', { params })
  },
  getById(id) {
    return request.get(`/records/${id}`)
  },
  create(data) {
    return request.post('/records', data)
  },
  update(id, data) {
    return request.put(`/records/${id}`, data)
  },
  remove(id) {
    return request.delete(`/records/${id}`)
  }
}
