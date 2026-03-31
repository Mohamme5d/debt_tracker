import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { FormsModule } from '@angular/forms';
import { NgSelectModule } from '@ng-select/ng-select';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';
import { LanguageService } from '../../core/services/language.service';
import { ToastService } from '../../core/services/toast.service';
import { RentPayment, RentContract, Renter, Apartment } from '../../core/models';

interface PagedResult<T> { items: T[]; totalCount: number; page: number; pageSize: number; }

@Component({
  selector: 'app-payments',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, FormsModule, NgSelectModule],
  template: `
    <div class="page-header">
      <h2>{{ lang.t('payments') }}</h2>
      <div style="display:flex;gap:8px">
        <button class="btn btn-primary" (click)="openModal()">
          <span class="material-icons">add</span> {{ lang.t('addPayment') }}
        </button>
        @if (isOwner()) {
          <button class="btn btn-accent" (click)="generateMonth()">
            <span class="material-icons">auto_awesome</span> {{ lang.t('generateThisMonth') }}
          </button>
        }
      </div>
    </div>

    <div class="card">
      <!-- ── Modern Filter Panel ── -->
      <div class="filter-panel">
        <div class="filter-panel__header" (click)="filtersOpen = !filtersOpen">
          <div class="filter-panel__title">
            <span class="material-icons" style="font-size:18px;opacity:.6">filter_list</span>
            <span>{{ lang.t('filters') }}</span>
            @if (activeFilterCount) {
              <span class="filter-count">{{ activeFilterCount }}</span>
            }
          </div>
          <div style="display:flex;align-items:center;gap:6px">
            @if (activeFilterCount) {
              <button class="filter-clear-btn" (click)="clearFilters(); $event.stopPropagation()">
                <span class="material-icons" style="font-size:14px">close</span>
                {{ lang.t('clear') || 'Clear' }}
              </button>
            }
            <span class="material-icons filter-panel__chevron" [class.open]="filtersOpen">expand_more</span>
          </div>
        </div>

        @if (filtersOpen) {
          <div class="filter-panel__body">
            <div class="filter-grid">
              <div class="filter-item">
                <label class="filter-label">
                  <span class="material-icons" style="font-size:14px">person</span>
                  {{ lang.t('renter') }}
                </label>
                <ng-select
                  [items]="renters()"
                  bindValue="id"
                  bindLabel="name"
                  [(ngModel)]="filterRenterId"
                  [placeholder]="lang.t('allRenters')"
                  [clearable]="true"
                  appendTo="body"
                  (change)="onFilterChange()">
                </ng-select>
              </div>
              <div class="filter-item">
                <label class="filter-label">
                  <span class="material-icons" style="font-size:14px">apartment</span>
                  {{ lang.t('apartment') }}
                </label>
                <ng-select
                  [items]="apartments()"
                  bindValue="id"
                  bindLabel="name"
                  [(ngModel)]="filterApartmentId"
                  [placeholder]="lang.t('allApartments')"
                  [clearable]="true"
                  appendTo="body"
                  (change)="onFilterChange()">
                </ng-select>
              </div>
              <div class="filter-item">
                <label class="filter-label">
                  <span class="material-icons" style="font-size:14px">calendar_month</span>
                  {{ lang.t('month') }}
                </label>
                <select class="form-control" [(ngModel)]="filterMonthVal" (change)="onFilterChange()">
                  <option [ngValue]="0">—</option>
                  @for (m of months; track m.v) {
                    <option [ngValue]="m.v">{{ m.label }}</option>
                  }
                </select>
              </div>
              <div class="filter-item">
                <label class="filter-label">
                  <span class="material-icons" style="font-size:14px">date_range</span>
                  {{ lang.t('year') }}
                </label>
                <input class="form-control" type="number" [(ngModel)]="filterYearVal"
                  [placeholder]="lang.t('year')" (input)="onFilterChange()" min="2020">
              </div>
              <div class="filter-item">
                <label class="filter-label">
                  <span class="material-icons" style="font-size:14px">flag</span>
                  {{ lang.t('status') }}
                </label>
                <select class="form-control" [(ngModel)]="filterStatusVal" (change)="onFilterChange()">
                  <option value="">{{ lang.t('allStatuses') }}</option>
                  <option value="Draft">{{ lang.t('pending') }}</option>
                  <option value="Approved">{{ lang.t('approved') }}</option>
                  <option value="Rejected">{{ lang.t('rejected') }}</option>
                </select>
              </div>
            </div>
          </div>
        }

        <!-- Sort bar (always visible) -->
        <div class="sort-bar">
          <div class="sort-bar__left">
            @if (totalCount > 0) {
              <span class="results-count">
                {{ totalCount }} {{ lang.t('results') || 'results' }}
              </span>
            }
          </div>
          <div class="sort-bar__right">
            <div class="sort-control">
              <span class="sort-control__label">{{ lang.t('sortBy') }}:</span>
              @for (opt of sortOptions; track opt.value) {
                <button class="sort-chip" [class.active]="sortFieldVal === opt.value"
                  (click)="onSortChipClick(opt.value)">
                  {{ opt.label }}
                  @if (sortFieldVal === opt.value) {
                    <span class="material-icons sort-chip__arrow">{{ sortDirVal === 'asc' ? 'arrow_upward' : 'arrow_downward' }}</span>
                  }
                </button>
              }
            </div>
          </div>
        </div>
      </div>

      <!-- Table -->
      <table class="data-table">
        <thead>
          <tr>
            <th>{{ lang.t('apartment') }}</th>
            <th>{{ lang.t('renter') }}</th>
            <th>{{ lang.t('period') }}</th>
            <th>{{ lang.t('rent') }}</th>
            <th>{{ lang.t('paid') }}</th>
            <th>{{ lang.t('outstanding') }}</th>
            <th>{{ lang.t('status') }}</th>
            <th class="col-actions"></th>
          </tr>
        </thead>
        <tbody>
          @for (p of payments(); track p.id) {
            <tr>
              <td>{{ p.apartmentName }}</td>
              <td>{{ p.renterName || '—' }}</td>
              <td>{{ p.paymentMonth }}/{{ p.paymentYear }}</td>
              <td>{{ p.rentAmount | number:'1.0-0' }}</td>
              <td>{{ p.amountPaid | number:'1.0-0' }}</td>
              <td [style.color]="p.outstandingAfter > 0 ? 'var(--warn)' : 'inherit'">
                {{ p.outstandingAfter | number:'1.0-0' }}
              </td>
              <td>
                <span class="badge" [class]="statusClass(p.status)">
                  {{ lang.t(p.status?.toLowerCase() || 'pending') }}
                </span>
              </td>
              <td class="col-actions">
                <button class="btn-icon" (click)="openModal(p)" [title]="lang.t('edit')">
                  <span class="material-icons">edit</span>
                </button>
                @if (isOwner()) {
                  <button class="btn-icon btn-icon-warn" (click)="delete(p.id)" [title]="lang.t('delete')">
                    <span class="material-icons">delete</span>
                  </button>
                }
              </td>
            </tr>
          }
        </tbody>
      </table>
      @if (!totalCount) {
        <div class="empty-state">{{ lang.t('noPaymentsYet') }}</div>
      }

      <!-- ── Modern Pagination ── -->
      @if (totalCount > 0) {
        <div class="pagination-bar">
          <div class="pagination-bar__info">
            <span class="pagination-bar__label">{{ lang.t('rowsPerPage') }}:</span>
            <select class="pagination-select" [(ngModel)]="pageSizeVal" (change)="onPageSizeChange()">
              <option [ngValue]="10">10</option>
              <option [ngValue]="25">25</option>
              <option [ngValue]="50">50</option>
            </select>
          </div>
          <div class="pagination-bar__nav">
            <span class="pagination-bar__range">
              {{ (currentPageVal - 1) * pageSizeVal + 1 }}–{{ mathMin(currentPageVal * pageSizeVal, totalCount) }}
              <span style="opacity:.5">of</span>
              {{ totalCount }}
            </span>
            <div class="pagination-btn-group">
              <button class="pagination-btn" [disabled]="currentPageVal <= 1" (click)="prevPage()">
                <span class="material-icons">chevron_left</span>
              </button>
              @for (pg of getPageNumbers(); track pg) {
                @if (pg === -1) {
                  <span class="pagination-ellipsis">…</span>
                } @else {
                  <button class="pagination-btn pagination-btn--page" [class.active]="pg === currentPageVal"
                    (click)="goToPage(pg)">
                    {{ pg }}
                  </button>
                }
              }
              <button class="pagination-btn" [disabled]="currentPageVal >= totalPagesVal" (click)="nextPage()">
                <span class="material-icons">chevron_right</span>
              </button>
            </div>
          </div>
        </div>
      }
    </div>

    @if (showModal()) {
      <div class="modal-overlay" (click)="closeModal()">
        <div class="modal" (click)="$event.stopPropagation()">
          <div class="modal-header">
            <h3>{{ editItem() ? lang.t('editPayment') : lang.t('addPayment') }}</h3>
          </div>
          <div class="modal-body">
            <form [formGroup]="form">
              <div class="form-group">
                <label class="form-label">{{ lang.t('contract') }}</label>
                <ng-select
                  [items]="contracts()"
                  bindValue="id"
                  formControlName="contractId"
                  [placeholder]="lang.t('selectContract')"
                  appendTo="body"
                  (change)="onContractSelect($event)">
                  <ng-template ng-label-tmp let-item="item">
                    {{ item.renterName }} — {{ item.apartmentName }}
                  </ng-template>
                  <ng-template ng-option-tmp let-item="item">
                    {{ item.renterName }} — {{ item.apartmentName }} | {{ item.monthlyRent | number:'1.0-0' }}
                  </ng-template>
                </ng-select>
              </div>
              <div style="display:flex;gap:10px">
                <div class="form-group" style="flex:1">
                  <label class="form-label">{{ lang.t('month') }} *</label>
                  <input class="form-control" type="number" formControlName="paymentMonth" min="1" max="12">
                </div>
                <div class="form-group" style="flex:1">
                  <label class="form-label">{{ lang.t('year') }} *</label>
                  <input class="form-control" type="number" formControlName="paymentYear" min="2020">
                </div>
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('rentAmount') }} *</label>
                <input class="form-control" type="number" formControlName="rentAmount">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('outstandingBefore') }}</label>
                <input class="form-control" type="number" formControlName="outstandingBefore">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('amountPaid') }} *</label>
                <input class="form-control" type="number" formControlName="amountPaid">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('notes') }}</label>
                <textarea class="form-control" formControlName="notes"></textarea>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button class="btn btn-outline" (click)="closeModal()">{{ lang.t('cancel') }}</button>
            <button class="btn btn-primary" (click)="save()" [disabled]="form.invalid">{{ lang.t('save') }}</button>
          </div>
        </div>
      </div>
    }
  `,
  styles: [`
    /* ── Filter Panel ── */
    .filter-panel {
      border-bottom: 1px solid var(--border);
    }
    .filter-panel__header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 12px 16px;
      cursor: pointer;
      user-select: none;
      transition: background .15s;
    }
    .filter-panel__header:hover {
      background: rgba(129, 140, 248, .04);
    }
    .filter-panel__title {
      display: flex;
      align-items: center;
      gap: 6px;
      font-size: 13px;
      font-weight: 500;
      letter-spacing: .3px;
      text-transform: uppercase;
      color: var(--text-dim);
    }
    .filter-count {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      min-width: 18px;
      height: 18px;
      padding: 0 5px;
      border-radius: 9px;
      background: var(--primary);
      color: #fff;
      font-size: 11px;
      font-weight: 600;
    }
    .filter-clear-btn {
      display: inline-flex;
      align-items: center;
      gap: 3px;
      padding: 3px 8px;
      border: none;
      border-radius: 4px;
      background: rgba(248, 113, 113, .12);
      color: var(--warn);
      font-size: 11px;
      font-weight: 500;
      cursor: pointer;
      transition: background .15s;
    }
    .filter-clear-btn:hover {
      background: rgba(248, 113, 113, .22);
    }
    .filter-panel__chevron {
      font-size: 18px;
      opacity: .5;
      transition: transform .2s ease;
    }
    .filter-panel__chevron.open {
      transform: rotate(180deg);
    }
    .filter-panel__body {
      padding: 0 16px 14px;
      animation: filterSlideIn .15s ease;
    }
    @keyframes filterSlideIn {
      from { opacity: 0; transform: translateY(-6px); }
      to   { opacity: 1; transform: translateY(0); }
    }
    .filter-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
      gap: 12px;
    }
    .filter-item {
      display: flex;
      flex-direction: column;
      gap: 4px;
    }
    .filter-label {
      display: flex;
      align-items: center;
      gap: 4px;
      font-size: 11px;
      font-weight: 500;
      letter-spacing: .3px;
      text-transform: uppercase;
      color: var(--text-dim);
    }

    /* ── Sort Bar ── */
    .sort-bar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      flex-wrap: wrap;
      gap: 8px;
      padding: 10px 16px;
      border-top: 1px solid var(--border);
    }
    .sort-bar__left, .sort-bar__right {
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .results-count {
      font-size: 12px;
      color: var(--text-dim);
      font-weight: 500;
    }
    .sort-control {
      display: flex;
      align-items: center;
      gap: 4px;
    }
    .sort-control__label {
      font-size: 12px;
      color: var(--text-dim);
      margin-inline-end: 4px;
    }
    .sort-chip {
      display: inline-flex;
      align-items: center;
      gap: 2px;
      padding: 4px 10px;
      border: 1px solid var(--border);
      border-radius: 14px;
      background: transparent;
      color: var(--text-dim);
      font-size: 12px;
      font-weight: 500;
      cursor: pointer;
      transition: all .15s;
    }
    .sort-chip:hover {
      border-color: var(--primary);
      color: var(--primary);
      background: rgba(129, 140, 248, .06);
    }
    .sort-chip.active {
      border-color: var(--primary);
      background: rgba(129, 140, 248, .12);
      color: var(--primary);
    }
    .sort-chip__arrow {
      font-size: 13px !important;
    }

    /* ── Pagination Bar ── */
    .pagination-bar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      flex-wrap: wrap;
      gap: 12px;
      padding: 12px 16px;
      border-top: 1px solid var(--border);
    }
    .pagination-bar__info {
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .pagination-bar__label {
      font-size: 13px;
      color: var(--text-dim);
    }
    .pagination-select {
      background: var(--surface-2);
      border: 1px solid var(--border);
      border-radius: var(--radius-sm);
      color: var(--text);
      padding: 3px 8px;
      font-size: 13px;
    }
    .pagination-bar__nav {
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .pagination-bar__range {
      font-size: 13px;
      color: var(--text-dim);
    }
    .pagination-btn-group {
      display: flex;
      align-items: center;
      gap: 2px;
    }
    .pagination-btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      min-width: 30px;
      height: 30px;
      padding: 0 4px;
      border: 1px solid var(--border);
      border-radius: var(--radius-sm);
      background: transparent;
      color: var(--text-dim);
      font-size: 13px;
      cursor: pointer;
      transition: all .15s;
    }
    .pagination-btn:hover:not(:disabled) {
      border-color: var(--primary);
      color: var(--primary);
      background: rgba(129, 140, 248, .06);
    }
    .pagination-btn:disabled {
      opacity: .3;
      cursor: default;
    }
    .pagination-btn--page.active {
      background: var(--primary);
      border-color: var(--primary);
      color: #fff;
      font-weight: 600;
    }
    .pagination-ellipsis {
      padding: 0 4px;
      color: var(--text-dim);
      font-size: 13px;
    }

    /* ── Responsive ── */
    @media (max-width: 640px) {
      .filter-grid { grid-template-columns: 1fr 1fr; }
      .sort-chip span.sort-chip__arrow { display: none; }
      .pagination-bar { flex-direction: column; align-items: stretch; }
      .pagination-bar__nav { justify-content: center; }
    }
  `]
})
export class PaymentsComponent implements OnInit {
  private api = inject(ApiService);
  private auth = inject(AuthService);
  lang = inject(LanguageService);
  toast = inject(ToastService);

  form = inject(FormBuilder).group({
    contractId:        [null as string | null],
    paymentMonth:      [new Date().getMonth() + 1, [Validators.required, Validators.min(1), Validators.max(12)]],
    paymentYear:       [new Date().getFullYear(), Validators.required],
    rentAmount:        [0, [Validators.required, Validators.min(0)]],
    outstandingBefore: [0],
    amountPaid:        [0, Validators.required],
    notes:             ['']
  });

  payments  = signal<RentPayment[]>([]);
  contracts = signal<RentContract[]>([]);
  renters   = signal<Renter[]>([]);
  apartments= signal<Apartment[]>([]);
  isOwner   = signal(this.auth.isOwner);
  showModal = signal(false);
  editItem  = signal<RentPayment | null>(null);

  // Filter panel
  filtersOpen = true;
  filterRenterId:    string | null = null;
  filterApartmentId: string | null = null;
  filterMonthVal  = 0;
  filterYearVal   = '';
  filterStatusVal = '';

  get activeFilterCount(): number {
    let c = 0;
    if (this.filterRenterId) c++;
    if (this.filterApartmentId) c++;
    if (this.filterMonthVal) c++;
    if (this.filterYearVal?.trim()) c++;
    if (this.filterStatusVal) c++;
    return c;
  }

  // Sort state
  sortFieldVal: string = 'period';
  sortDirVal: 'asc' | 'desc' = 'desc';

  readonly sortOptions = [
    { value: 'period', label: 'Period' },
    { value: 'renterName', label: 'Renter' },
    { value: 'apartmentName', label: 'Apartment' },
    { value: 'amountPaid', label: 'Amount' },
    { value: 'status', label: 'Status' },
  ];

  // Pagination state
  pageSizeVal    = 25;
  currentPageVal = 1;
  totalPagesVal  = 1;
  totalCount     = 0;

  readonly months = [
    { v: 1, label: 'Jan' }, { v: 2, label: 'Feb' }, { v: 3, label: 'Mar' },
    { v: 4, label: 'Apr' }, { v: 5, label: 'May' }, { v: 6, label: 'Jun' },
    { v: 7, label: 'Jul' }, { v: 8, label: 'Aug' }, { v: 9, label: 'Sep' },
    { v: 10, label: 'Oct' }, { v: 11, label: 'Nov' }, { v: 12, label: 'Dec' },
  ];

  mathMin = Math.min;

  ngOnInit() {
    this.load();
    this.api.get<RentContract[]>('/contracts').subscribe(data => this.contracts.set(data));
    this.api.get<Renter[]>('/renters').subscribe(data => this.renters.set(data));
    this.api.get<Apartment[]>('/apartments').subscribe(data => this.apartments.set(data));
  }

  private buildParams(): Record<string, string | number> {
    const p: Record<string, string | number> = {
      page:     this.currentPageVal,
      pageSize: this.pageSizeVal,
      sortBy:   this.sortFieldVal,
      sortDir:  this.sortDirVal,
    };
    if (this.filterMonthVal)          p['month']       = this.filterMonthVal;
    if (this.filterYearVal?.trim())   p['year']        = Number(this.filterYearVal.trim());
    if (this.filterRenterId)          p['renterId']    = this.filterRenterId;
    if (this.filterApartmentId)       p['apartmentId'] = this.filterApartmentId;
    if (this.filterStatusVal)         p['status']      = this.filterStatusVal;
    return p;
  }

  load() {
    this.api.get<PagedResult<RentPayment>>('/payments', this.buildParams()).subscribe(result => {
      this.payments.set(result.items);
      this.totalCount    = result.totalCount;
      this.totalPagesVal = Math.max(1, Math.ceil(result.totalCount / this.pageSizeVal));
    });
  }

  onFilterChange() {
    this.currentPageVal = 1;
    this.load();
  }

  clearFilters() {
    this.filterRenterId = null;
    this.filterApartmentId = null;
    this.filterMonthVal = 0;
    this.filterYearVal = '';
    this.filterStatusVal = '';
    this.currentPageVal = 1;
    this.load();
  }

  onSortChipClick(field: string) {
    if (this.sortFieldVal === field) {
      this.sortDirVal = this.sortDirVal === 'asc' ? 'desc' : 'asc';
    } else {
      this.sortFieldVal = field;
      this.sortDirVal = 'asc';
    }
    this.currentPageVal = 1;
    this.load();
  }

  toggleSort() {
    this.sortDirVal = this.sortDirVal === 'asc' ? 'desc' : 'asc';
    this.currentPageVal = 1;
    this.load();
  }

  onPageSizeChange() {
    this.currentPageVal = 1;
    this.load();
  }

  prevPage() {
    if (this.currentPageVal > 1) { this.currentPageVal--; this.load(); }
  }

  nextPage() {
    if (this.currentPageVal < this.totalPagesVal) { this.currentPageVal++; this.load(); }
  }

  goToPage(pg: number) {
    this.currentPageVal = pg;
    this.load();
  }

  getPageNumbers(): number[] {
    const total = this.totalPagesVal;
    const cur = this.currentPageVal;
    if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);
    const pages: number[] = [1];
    if (cur > 3) pages.push(-1);
    for (let i = Math.max(2, cur - 1); i <= Math.min(total - 1, cur + 1); i++) pages.push(i);
    if (cur < total - 2) pages.push(-1);
    if (total > 1) pages.push(total);
    return pages;
  }

  statusClass(status?: string) {
    if (status === 'Approved') return 'badge badge-primary';
    if (status === 'Rejected') return 'badge badge-warn';
    return 'badge badge-accent';
  }

  openModal(payment?: RentPayment) {
    this.editItem.set(payment ?? null);
    this.form.reset({
      contractId: payment?.contractId ?? null,
      paymentMonth: payment?.paymentMonth ?? new Date().getMonth() + 1,
      paymentYear: payment?.paymentYear ?? new Date().getFullYear(),
      rentAmount: payment?.rentAmount ?? 0,
      outstandingBefore: payment?.outstandingBefore ?? 0,
      amountPaid: payment?.amountPaid ?? 0,
      notes: payment?.notes ?? ''
    });
    this.showModal.set(true);
  }

  closeModal() { this.showModal.set(false); this.editItem.set(null); }

  onContractSelect(contract: RentContract | null) {
    if (contract) this.form.patchValue({ rentAmount: contract.monthlyRent });
  }

  save() {
    if (this.form.invalid) return;
    const v = this.form.value;
    const body = {
      contractId: v.contractId || null,
      apartmentId: null,
      paymentMonth: Number(v.paymentMonth),
      paymentYear: Number(v.paymentYear),
      rentAmount: Number(v.rentAmount),
      outstandingBefore: Number(v.outstandingBefore),
      amountPaid: Number(v.amountPaid),
      isVacant: !v.contractId,
      notes: v.notes || null
    };
    const p = this.editItem();
    const obs = p
      ? this.api.put(`/payments/${p.id}`, body)
      : this.api.post('/payments', body);
    obs.subscribe({
      next: () => { this.toast.show(this.lang.t('saved')); this.closeModal(); this.load(); },
      error: e => this.toast.show(e.error?.message || 'Error', 'error')
    });
  }

  delete(id: string) {
    if (!confirm(this.lang.t('delete') + '?')) return;
    this.api.delete(`/payments/${id}`).subscribe({
      next: () => this.load(),
      error: e => this.toast.show(e.error?.message || 'Delete failed', 'error')
    });
  }

  generateMonth() {
    const now = new Date();
    this.api.post<RentPayment[]>('/payments/generate-month', { month: now.getMonth() + 1, year: now.getFullYear() }).subscribe({
      next: (created) => { this.toast.show(`${this.lang.t('generateThisMonth')}: ${created.length}`); this.load(); },
      error: e => this.toast.show(e.error?.message || 'Error', 'error')
    });
  }
}
