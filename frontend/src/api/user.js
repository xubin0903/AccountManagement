import request from './request'

export const userApi = {
  login(data) {
    return request.post('/users/login', data)
  },
  register(data) {
    return request.post('/users', data)
  },
  getById(id) {
    return request.get(`/users/${id}`)
  },
  list() {
    return request.get('/users')
  }
}
