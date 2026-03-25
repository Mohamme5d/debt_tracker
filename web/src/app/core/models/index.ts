export interface AuthResponse { accessToken: string; refreshToken: string; user: UserDto; }
export interface UserDto { id: string; tenantId: string; name: string; email: string; role: 'Owner' | 'Employee' | 'SuperAdmin'; phone?: string; isActive: boolean; }
export interface Apartment { id: string; name: string; address?: string; description?: string; notes?: string; createdAt: string; }
export interface Renter { id: string; apartmentId: string; apartmentName: string; name: string; phone?: string; email?: string; monthlyRent: number; startDate: string; isActive: boolean; notes?: string; status: string; createdAt: string; }
export interface RentPayment { id: string; renterId?: string; renterName?: string; apartmentId: string; apartmentName: string; paymentMonth: number; paymentYear: number; rentAmount: number; outstandingBefore: number; amountPaid: number; outstandingAfter: number; isVacant: boolean; notes?: string; status: string; createdAt: string; }
export interface Expense { id: string; description: string; amount: number; expenseDate: string; category?: string; month: number; year: number; notes?: string; status: string; createdAt: string; }
export interface MonthlyDeposit { id: string; depositMonth: number; depositYear: number; amount: number; notes?: string; status: string; createdAt: string; }
export interface ApprovalRequest { id: string; entityType: string; entityId: string; action: string; status: string; submittedByName: string; submittedByEmail: string; reviewedByName?: string; reviewNotes?: string; createdAt: string; reviewedAt?: string; }
export interface Notification { id: string; title: string; body: string; isRead: boolean; entityType?: string; entityId?: string; createdAt: string; }
export interface DashboardStats { totalApartments: number; activeRenters: number; totalCollectedThisMonth: number; totalOutstanding: number; totalExpensesThisMonth: number; pendingApprovals: number; unreadNotifications: number; }

// ── Admin / Platform models ───────────────────────────────────────────────────
export interface PlatformStats { totalTenants: number; activeTenants: number; inactiveTenants: number; totalUsers: number; totalApartments: number; totalActiveRenters: number; newTenantsThisMonth: number; }
export interface AdminTenantListItem { id: string; name: string; email: string; plan: string; isActive: boolean; createdAt: string; userCount: number; apartmentCount: number; activeRenterCount: number; }
export interface AdminTenantDetail { id: string; name: string; email: string; plan: string; isActive: boolean; createdAt: string; users: AdminUser[]; apartmentCount: number; activeRenterCount: number; totalPayments: number; }
export interface AdminUser { id: string; tenantId: string; tenantName: string; name: string; email: string; role: string; phone?: string; isActive: boolean; createdAt: string; }
