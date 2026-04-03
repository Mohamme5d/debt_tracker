import { Component, OnInit, signal, computed, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { FormsModule } from '@angular/forms';
import { NgSelectModule } from '@ng-select/ng-select';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';
import { LanguageService } from '../../core/services/language.service';
import { ToastService } from '../../core/services/toast.service';
import { RentContract, Renter, Apartment } from '../../core/models';

const PAGE_SIZE = 10;

@Component({
  selector: 'app-contracts',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, FormsModule, NgSelectModule],
  template: `
    <div class="page-header page-enter">
      <h2>{{ lang.t('contracts') }}</h2>
      <button class="btn btn-primary" (click)="openModal()">
        <span class="material-icons">add</span> {{ lang.t('addContract') }}
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
            <div class="skeleton skeleton-cell" style="width:20%;"></div>
            <div class="skeleton skeleton-cell" style="width:20%;"></div>
            <div class="skeleton skeleton-cell" style="width:12%;"></div>
            <div class="skeleton skeleton-cell" style="width:13%;"></div>
            <div class="skeleton skeleton-cell" style="width:13%;"></div>
            <div class="skeleton skeleton-cell" style="width:8%;border-radius:999px"></div>
            <div class="skeleton skeleton-cell" style="width:6%;margin-inline-start:auto"></div>
          </div>
        }
      } @else {
        <table class="data-table">
          <thead>
            <tr>
              <th>{{ lang.t('renter') }}</th>
              <th>{{ lang.t('apartment') }}</th>
              <th>{{ lang.t('monthlyRent') }}</th>
              <th>{{ lang.t('startDate') }}</th>
              <th>{{ lang.t('endDate') }}</th>
              <th>{{ lang.t('isActive') }}</th>
              <th>{{ lang.t('status') }}</th>
              <th class="col-actions"></th>
            </tr>
          </thead>
          <tbody>
            @for (c of paged(); track c.id) {
              <tr>
                <td>{{ c.renterName }}</td>
                <td>{{ c.apartmentName }}</td>
                <td>{{ c.monthlyRent | number:'1.0-0' }}</td>
                <td>{{ c.startDate }}</td>
                <td>{{ c.endDate || '—' }}</td>
                <td>
                  <span class="badge" [class]="c.isActive ? 'badge-primary' : 'badge-muted'">
                    {{ c.isActive ? lang.t('active') : lang.t('inactive') }}
                  </span>
                </td>
                <td>
                  <span class="badge" [class]="statusClass(c.status)">{{ c.status }}</span>
                </td>
                <td class="col-actions">
                  <button class="btn-icon" (click)="openModal(c)" [title]="lang.t('edit')">
                    <span class="material-icons">edit</span>
                  </button>
                  @if (isOwner()) {
                    <button class="btn-icon btn-icon-warn" (click)="delete(c.id)" [title]="lang.t('delete')">
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
            {{ searchQ ? lang.t('noResults') : lang.t('noContractsYet') }}
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
            <h3>{{ editItem() ? lang.t('editContract') : lang.t('addContract') }}</h3>
          </div>
          <div class="modal-body">
            <form [formGroup]="form">
              <div class="form-group">
                <label class="form-label">{{ lang.t('renter') }} *</label>
                <ng-select
                  [items]="renters()"
                  bindLabel="name"
                  bindValue="id"
                  formControlName="renterId"
                  [placeholder]="lang.t('selectRenter')"
                  appendTo="body">
                </ng-select>
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('apartment') }} *</label>
                <ng-select
                  [items]="apartments()"
                  bindLabel="name"
                  bindValue="id"
                  formControlName="apartmentId"
                  [placeholder]="lang.t('selectApartment')"
                  appendTo="body">
                </ng-select>
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('monthlyRent') }} *</label>
                <input class="form-control" type="number" formControlName="monthlyRent">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('startDate') }} *</label>
                <input class="form-control" type="date" formControlName="startDate">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('endDate') }}</label>
                <input class="form-control" type="date" formControlName="endDate">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('notes') }}</label>
                <textarea class="form-control" formControlName="notes"></textarea>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button class="btn btn-outline" (click)="closeModal()">{{ lang.t('cancel') }}</button>
            <button class="btn btn-primary" (click)="save()" [disabled]="form.invalid || saving()">{{ lang.t('save') }}</button>
          </div>
        </div>
      </div>
    }
  `
})
export class ContractsComponent implements OnInit {
  private api = inject(ApiService);
  private auth = inject(AuthService);
  lang = inject(LanguageService);
  toast = inject(ToastService);

  form = inject(FormBuilder).group({
    renterId:    ['', Validators.required],
    apartmentId: ['', Validators.required],
    monthlyRent: [0, [Validators.required, Validators.min(0)]],
    startDate:   ['', Validators.required],
    endDate:     [''],
    notes:       ['']
  });

  allContracts = signal<RentContract[]>([]);
  renters = signal<Renter[]>([]);
  apartments = signal<Apartment[]>([]);
  loading = signal(true);
  saving = signal(false);
  isOwner = signal(this.auth.isOwner);
  showModal = signal(false);
  editItem = signal<RentContract | null>(null);
  page = signal(1);
  searchQ = '';
  skeletons = [1, 2, 3, 4, 5];

  filtered = computed(() => {
    const q = this.searchQ.toLowerCase().trim();
    if (!q) return this.allContracts();
    return this.allContracts().filter(c =>
      c.renterName.toLowerCase().includes(q) ||
      c.apartmentName.toLowerCase().includes(q) ||
      String(c.monthlyRent).includes(q)
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
    this.load();
    this.api.get<Renter[]>('/renters').subscribe(data => this.renters.set(data));
    this.api.get<Apartment[]>('/apartments').subscribe(data => this.apartments.set(data));
  }

  load() {
    this.loading.set(true);
    this.api.get<RentContract[]>('/contracts').subscribe({
      next: data => { this.allContracts.set(data); this.loading.set(false); },
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

  openModal(contract?: RentContract) {
    this.editItem.set(contract ?? null);
    this.form.reset({ renterId: '', apartmentId: '', monthlyRent: 0, startDate: '', endDate: '', notes: '' });
    if (contract) {
      this.form.patchValue({
        renterId: contract.renterId,
        apartmentId: contract.apartmentId,
        monthlyRent: contract.monthlyRent,
        startDate: contract.startDate,
        endDate: contract.endDate || '',
        notes: contract.notes || ''
      });
    }
    this.showModal.set(true);
  }

  closeModal() { this.showModal.set(false); this.editItem.set(null); }

  save() {
    if (this.form.invalid) return;
    this.saving.set(true);
    const v = this.form.value;
    const body = {
      renterId: v.renterId,
      apartmentId: v.apartmentId,
      monthlyRent: Number(v.monthlyRent),
      startDate: v.startDate,
      endDate: v.endDate || null,
      notes: v.notes || null
    };
    const c = this.editItem();
    const obs = c ? this.api.put(`/contracts/${c.id}`, body) : this.api.post('/contracts', body);
    obs.subscribe({
      next: () => { this.toast.show(this.lang.t('saved')); this.closeModal(); this.load(); this.saving.set(false); },
      error: e => { this.toast.show(e.error?.message || 'Error', 'error'); this.saving.set(false); }
    });
  }

  delete(id: string) {
    if (!confirm(this.lang.t('delete') + '?')) return;
    this.api.delete(`/contracts/${id}`).subscribe({
      next: () => this.load(),
      error: e => this.toast.show(e.error?.message || 'Delete failed', 'error')
    });
  }
}
