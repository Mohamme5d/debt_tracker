import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class ApiService {
  constructor(private http: HttpClient) {}

  get<T>(path: string, params?: Record<string, string | number>): Observable<T> {
    let p = new HttpParams();
    if (params) Object.entries(params).forEach(([k, v]) => p = p.set(k, String(v)));
    return this.http.get<T>(`/api${path}`, { params: p });
  }
  getBlob(path: string, params?: Record<string, string | number>): Observable<Blob> {
    let p = new HttpParams();
    if (params) Object.entries(params).forEach(([k, v]) => p = p.set(k, String(v)));
    return this.http.get(`/api${path}`, { params: p, responseType: 'blob' });
  }
  post<T>(path: string, body: unknown): Observable<T> { return this.http.post<T>(`/api${path}`, body); }
  put<T>(path: string, body: unknown): Observable<T> { return this.http.put<T>(`/api${path}`, body); }
  delete<T>(path: string): Observable<T> { return this.http.delete<T>(`/api${path}`); }
}
