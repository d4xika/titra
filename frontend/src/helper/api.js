import axios from "axios";
import { Capacitor } from "@capacitor/core";

const defaultApiUrl = Capacitor.isNativePlatform()
  ? "https://titra.d4xika.com/api/"
  : "/api";
const storedAuthToken = localStorage.getItem("auth_token");

const API = axios.create({
  baseURL: import.meta.env.VITE_API_URL || defaultApiUrl,
  headers: {
    "Content-Type": "application/json",
    ...(storedAuthToken ? { Authorization: `Bearer ${storedAuthToken}` } : {}),
  },
});

export function setAuthToken(authToken) {
  if (authToken) {
    localStorage.setItem("auth_token", authToken);
    API.defaults.headers.common.Authorization = `Bearer ${authToken}`;
  } else {
    localStorage.removeItem("auth_token");
    delete API.defaults.headers.common.Authorization;
  }
}

export default API;
