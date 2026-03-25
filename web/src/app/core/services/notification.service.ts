import { Injectable, signal } from '@angular/core';
import { ApiService } from './api.service';
import { Notification } from '../models';

@Injectable({ providedIn: 'root' })
export class NotificationService {
  notifications = signal<Notification[]>([]);
  unreadCount = signal(0);

  constructor(private api: ApiService) {}

  load() {
    this.api.get<Notification[]>('/notifications').subscribe(data => {
      this.notifications.set(data);
      this.unreadCount.set(data.filter(n => !n.isRead).length);
    });
  }

  markRead(id: string) {
    return this.api.put(`/notifications/${id}/read`, {});
  }

  markAllRead() {
    return this.api.put('/notifications/read-all', {});
  }
}
