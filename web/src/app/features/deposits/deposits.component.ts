import { Component, OnInit, signal, computed, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../core/services/api.service';
import { LanguageService } from '../../core/services/language.service';
import { MonthlyDeposit } from '../../core/models';

const PAGE_SIZE = 10;

@Component({
  selector: 'app-deposits',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="page-header page-enter">
      <h2>{{ lang.t('monthlyDeposits') }}</h2>
    </div>

    <div class="card page-enter" style="animation-delay:0.05s">

      <!-- Search bar -->
      <div class="search-bar">
        <span class="material-icons">search</span>
        <input
          type="text"
          [(ngModel)]="searchQ"
          (ngModelChange)="onSearch()"
          [placeholder]="lang.t('search')"
        >
        @if (searchQ) {
          <button class="search-clear" (click)="searchQ = ''; onSearch()">
            <span class="material-icons">close</span>
          </button>
        }
      </div>

      @if (loading()) {
        @for (s of skeletons; track s) {
          <div class="skeleton-row">
            <div class="skeleton skeleton-cell" style="width:18%;"></div>
            <div class="skeleton skeleton-cell" style="width:18%;"></div>
            <div class="skeleton skeleton-cell" style="width:30%;"></div>
            <div class="skeleton skeleton-cell" style="width:9%;border-radius:999px;margin-inline-start:auto"></div>
          </div>
        }
      } @else {
        <table class="data-table">
          <thead>
            <tr>
              <th>{{ lang.t('period') }}</th>
              <th>{{ lang.t('amount') }}</th>
              <th>{{ lang.t('notes') }}</th>
              <th>{{ lang.t('status') }}</th>
            </tr>
          </thead>
          <tbody>
            @for (d of paged(); track d.id) {
              <tr>
                <td>{{ d.depositMonth }}/{{ d.depositYear }}</td>
                <td>{{ d.amount | number:'1.0-0' }}</td>
                <td>{{ d.notes || '—' }}</td>
                <td>
                  <span class="badge" [class]="statusClass(d.status)">
                    {{ lang.t(d.status?.toLowerCase() || 'pending') }}
                  </span>
                </td>
              </tr>
            }
          </tbody>
        </table>

        @if (!filtered().length) {
          <div class="empty-state">
            {{ searchQ ? lang.t('noResults') : lang.t('noDepositsYet') }}
          </div>
        }

        @if (totalPages() > 1) {
          <div class="pagination">
            <button class="page-btn" [disabled]="page() === 1" (click)="setPage(page() - 1)">
              <span class="material-icons">chevron_left</span>
            </button>
            @for (p of pageNumbers(); track p) {
              <button class="page-btn" [class.active]="p === page()" (click)="setPage(p)">{{ p }}</button>
            }
            <button class="page-btn" [disabled]="page() === totalPages()" (click)="setPage(page() + 1)">
              <span class="material-icons">chevron_right</span>
            </button>
            <span class="page-info">{{ page() }} {{ lang.t('pageOf') }} {{ totalPages() }}</span>
          </div>
        }
      }
    </div>
  `
})
export class DepositsComponent implements OnInit {
  private api = inject(ApiService);
  lang = inject(LanguageService);

  allDeposits = signal<MonthlyDeposit[]>([]);
  loading = signal(true);
  page = signal(1);
  searchQ = '';
  skeletons = [1, 2, 3, 4, 5];

  filtered = computed(() => {
    const q = this.searchQ.toLowerCase().trim();
    if (!q) return this.allDeposits();
    return this.allDeposits().filter(d =>
      `${d.depositMonth}/${d.depositYear}`.includes(q) ||
      String(d.amount).includes(q) ||
      (d.notes ?? '').toLowerCase().includes(q)
    );
  });

  totalPages = computed(() => Math.max(1, Math.ceil(this.filtered().length / PAGE_SIZE)));

  paged = computed(() => {
    const start = (this.page() - 1) * PAGE_SIZE;
    return this.filtered().slice(start, start + PAGE_SIZE);
  });

  pageNumbers = computed(() => {
    const total = this.totalPages();
    const cur = this.page();
    const pages: number[] = [];
    for (let i = Math.max(1, cur - 2); i <= Math.min(total, cur + 2); i++) pages.push(i);
    return pages;
  });

  ngOnInit() {
    this.api.get<MonthlyDeposit[]>('/deposits').subscribe({
      next: d => { this.allDeposits.set(d); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  onSearch() { this.page.set(1); }
  setPage(p: number) { this.page.set(p); }

  statusClass(status?: string) {
    if (status === 'Approved') return 'badge badge-primary';
    if (status === 'Rejected') return 'badge badge-warn';
    return 'badge badge-accent';
  }
}
