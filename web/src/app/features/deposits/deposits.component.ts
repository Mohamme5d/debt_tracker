import { Component, OnInit, signal, computed, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';
import { LanguageService } from '../../core/services/language.service';
import { ToastService } from '../../core/services/toast.service';
import { MonthlyDeposit } from '../../core/models';

const PAGE_SIZE = 10;

@Component({
  selector: 'app-deposits',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, FormsModule],
  template: `
    <div class="page-header page-enter">
      <h2>{{ lang.t('monthlyDeposits') }}</h2>
      <button class="btn btn-primary" (click)="openModal()">
        <span class="material-icons">add</span> {{ lang.t('addDeposit') }}
      </button>
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
              <th class="col-actions"></th>
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
                <td class="col-actions">
                  <button class="btn-icon" (click)="openModal(d)" [title]="lang.t('edit')">
                    <span class="material-icons">edit</span>
                  </button>
                  @if (isOwner()) {
                    <button class="btn-icon btn-icon-warn" (click)="delete(d.id)" [title]="lang.t('delete')">
                      <span class="material-icons">delete</span>
                    </button>
                  }
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

    @if (showModal()) {
      <div class="modal-overlay" (click)="closeModal()">
        <div class="modal" (click)="$event.stopPropagation()">
          <div class="modal-header">
            <h3>{{ editItem() ? lang.t('editDeposit') : lang.t('addDeposit') }}</h3>
          </div>
          <div class="modal-body">
            <form [formGroup]="form">
              <div class="form-row">
                <div class="form-group">
                  <label class="form-label">{{ lang.t('month') }} *</label>
                  <input class="form-control" type="number" min="1" max="12" formControlName="depositMonth">
                </div>
                <div class="form-group">
                  <label class="form-label">{{ lang.t('year') }} *</label>
                  <input class="form-control" type="number" min="2000" formControlName="depositYear">
                </div>
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('amount') }} *</label>
                <input class="form-control" type="number" min="0" step="0.01" formControlName="amount">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('notes') }}</label>
                <textarea class="form-control" formControlName="notes"></textarea>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button class="btn btn-outline" (click)="closeModal()">{{ lang.t('cancel') }}</button>
            <button class="btn btn-primary" (click)="save()" [disabled]="form.invalid || saving()">
              @if (saving()) { <span class="material-icons" style="animation:spin 0.8s linear infinite;font-size:16px">refresh</span> }
              {{ lang.t('save') }}
            </button>
          </div>
        </div>
      </div>
    }
  `,
  styles: [`@keyframes spin { to { transform: rotate(360deg); } } .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }`]
})
export class DepositsComponent implements OnInit {
  private api = inject(ApiService);
  private auth = inject(AuthService);
  lang = inject(LanguageService);
  toast = inject(ToastService);

  form = inject(FormBuilder).group({
    depositMonth: [new Date().getMonth() + 1, [Validators.required, Validators.min(1), Validators.max(12)]],
    depositYear: [new Date().getFullYear(), [Validators.required, Validators.min(2000)]],
    amount: [null as number | null, [Validators.required, Validators.min(0)]],
    notes: ['']
  });

  allDeposits = signal<MonthlyDeposit[]>([]);
  loading = signal(true);
  saving = signal(false);
  isOwner = signal(this.auth.isOwner);
  showModal = signal(false);
  editItem = signal<MonthlyDeposit | null>(null);
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

  ngOnInit() { this.load(); }

  load() {
    this.loading.set(true);
    this.api.get<MonthlyDeposit[]>('/deposits').subscribe({
      next: d => { this.allDeposits.set(d); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  onSearch() { this.page.set(1); }
  setPage(p: number) { this.page.set(p); }

  openModal(deposit?: MonthlyDeposit) {
    this.editItem.set(deposit ?? null);
    this.form.reset({
      depositMonth: deposit?.depositMonth ?? new Date().getMonth() + 1,
      depositYear: deposit?.depositYear ?? new Date().getFullYear(),
      amount: deposit?.amount ?? null,
      notes: deposit?.notes ?? ''
    });
    this.showModal.set(true);
  }

  closeModal() { this.showModal.set(false); this.editItem.set(null); }

  save() {
    if (this.form.invalid) return;
    this.saving.set(true);
    const item = this.editItem();
    const obs = item
      ? this.api.put(`/deposits/${item.id}`, this.form.value)
      : this.api.post('/deposits', this.form.value);
    obs.subscribe({
      next: () => { this.toast.show(this.lang.t('saved')); this.closeModal(); this.load(); this.saving.set(false); },
      error: e => { this.toast.show(e.error?.message || 'Error', 'error'); this.saving.set(false); }
    });
  }

  delete(id: string) {
    if (!confirm(this.lang.t('delete') + '?')) return;
    this.api.delete(`/deposits/${id}`).subscribe({
      next: () => this.load(),
      error: e => this.toast.show(e.error?.message || 'Delete failed', 'error')
    });
  }

  statusClass(status?: string) {
    if (status === 'Approved') return 'badge badge-primary';
    if (status === 'Rejected') return 'badge badge-warn';
    return 'badge badge-accent';
  }
}
