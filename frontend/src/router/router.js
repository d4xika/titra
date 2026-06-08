import { createWebHistory, createRouter } from 'vue-router'

const routes = [
    {
        path: '/clock',
        name: 'clock',
        component: () => import('@/views/mainView.vue')
    },
    {
        path: '/savedSessions',
        name: 'savedSessions',
        component: () => import('@/views/savedSessionsView.vue')
    },
    {
        path: '/',
        name: 'welcome',
        component: () => import('@/views/welcomeView.vue')
    }
]

export const router = createRouter({
    history: createWebHistory(),
    routes,
})
