import { Component, OnInit, signal, computed, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';
import { LanguageService } from '../../core/services/language.service';
import { ToastService } from '../../core/services/toast.service';
import { Apartment } from '../../core/models';

const PAGE_SIZE = 10;

@Component({
  selector: 'app-apartments',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, FormsModule],
  template: `
    <div class="page-header page-enter">
      <h2>{{ lang.t('apartments') }}</h2>
      @if (isOwner()) {
        <button class="btn btn-primary" (click)="openModal()">
          <span class="material-icons">add</span> {{ lang.t('addApartment') }}
        </button>
      }
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
        <!-- Skeleton rows -->
        @for (s of skeletons; track s) {
          <div class="skeleton-row">
            <div class="skeleton skeleton-cell" style="width:28%;"></div>
            <div class="skeleton skeleton-cell" style="width:32%;"></div>
            <div class="skeleton skeleton-cell" style="width:24%;"></div>
            <div class="skeleton skeleton-cell" style="width:8%;margin-inline-start:auto"></div>
          </div>
        }
      } @else {
        <table class="data-table">
          <thead>
            <tr>
              <th>{{ lang.t('name') }}</th>
              <th>{{ lang.t('address') }}</th>
              <th>{{ lang.t('description') }}</th>
              <th class="col-actions"></th>
            </tr>
          </thead>
          <tbody>
            @for (a of paged(); track a.id) {
              <tr>
                <td>{{ a.name }}</td>
                <td>{{ a.address || '—' }}</td>
                <td>{{ a.description || '—' }}</td>
                <td class="col-actions">
                  @if (isOwner()) {
                    <button class="btn-icon" (click)="openModal(a)" [title]="lang.t('edit')">
                      <span class="material-icons">edit</span>
                    </button>
                    <button class="btn-icon btn-icon-warn" (click)="delete(a.id)" [title]="lang.t('delete')">
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
            {{ searchQ ? lang.t('noResults') : lang.t('noApartmentsYet') }}
          </div>
        }

        <!-- Pagination -->
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
            <h3>{{ editItem() ? lang.t('editApartment') : lang.t('addApartment') }}</h3>
          </div>
          <div class="modal-body">
            <form [formGroup]="form">
              <div class="form-group">
                <label class="form-label">{{ lang.t('name') }} *</label>
                <input class="form-control" formControlName="name">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('address') }}</label>
                <input class="form-control" formControlName="address">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('description') }}</label>
                <textarea class="form-control" formControlName="description"></textarea>
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
  styles: [`@keyframes spin { to { transform: rotate(360deg); } }`]
})
export class ApartmentsComponent implements OnInit {
  private api = inject(ApiService);
  private auth = inject(AuthService);
  lang = inject(LanguageService);
  toast = inject(ToastService);

  form = inject(FormBuilder).group({
    name: ['', Validators.required],
    address: [''],
    description: [''],
    notes: ['']
  });

  allApartments = signal<Apartment[]>([]);
  loading = signal(true);
  saving = signal(false);
  isOwner = signal(this.auth.isOwner);
  showModal = signal(false);
  editItem = signal<Apartment | null>(null);
  page = signal(1);
  searchQ = '';
  skeletons = [1, 2, 3, 4, 5];

  filtered = computed(() => {
    const q = this.searchQ.toLowerCase().trim();
    if (!q) return this.allApartments();
    return this.allApartments().filter(a =>
      a.name.toLowerCase().includes(q) ||
      (a.address ?? '').toLowerCase().includes(q) ||
      (a.description ?? '').toLowerCase().includes(q)
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
    this.api.get<Apartment[]>('/apartments').subscribe({
      next: data => { this.allApartments.set(data); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  onSearch() { this.page.set(1); }
  setPage(p: number) { this.page.set(p); }

  openModal(apt?: Apartment) {
    this.editItem.set(apt ?? null);
    this.form.reset({ name: '', address: '', description: '', notes: '' });
    if (apt) this.form.patchValue(apt);
    this.showModal.set(true);
  }

  closeModal() { this.showModal.set(false); this.editItem.set(null); }

  save() {
    if (this.form.invalid) return;
    this.saving.set(true);
    const apt = this.editItem();
    const obs = apt
      ? this.api.put(`/apartments/${apt.id}`, this.form.value)
      : this.api.post('/apartments', this.form.value);
    obs.subscribe({
      next: () => { this.toast.show(this.lang.t('saved')); this.closeModal(); this.load(); this.saving.set(false); },
      error: e => { this.toast.show(e.error?.message || 'Error', 'error'); this.saving.set(false); }
    });
  }

  delete(id: string) {
    if (!confirm(this.lang.t('delete') + '?')) return;
    this.api.delete(`/apartments/${id}`).subscribe({
      next: () => this.load(),
      error: e => this.toast.show(e.error?.message || 'Delete failed', 'error')
    });
  }
}
