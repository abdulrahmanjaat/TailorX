# Firestore Data Isolation Architecture

## Overview

This document explains how customer, order, and measurement data is isolated per user in Firestore, ensuring multi-user safety and data persistence across login sessions.

## Data Structure

All user data is scoped to the authenticated user's UID using the following path structure:

```
users/{uid}                          - User profile
users/{uid}/customers/{customerId}   - Customer documents
users/{uid}/orders/{orderId}         - Order documents
users/{uid}/measurements/{measurementId} - Measurement documents
```

## Key Principles

### 1. User-Scoped Paths
- **ALL** Firestore operations use paths that include the user's UID
- **NEVER** save data at root level (e.g., `/customers`, `/orders`)
- Every repository method uses `_getCollectionPath()` which returns `users/{uid}/...`

### 2. Authentication-Based Access
- All repositories use `FirebaseAuth.instance.currentUser.uid` to get the user ID
- This ensures the UID comes from Firebase Auth, not local storage
- Firestore security rules verify `request.auth.uid` matches the path's `{userId}`

### 3. Data Persistence
- **Data is NOT deleted on logout** - this is intentional and correct
- When a user logs out, only local secure storage is cleared
- Firestore data remains under `users/{uid}/...` 
- When the user logs back in, they see their same data because it's scoped to their UID

### 4. Multi-User Isolation
- Each user can ONLY access data under their own UID path
- User A cannot see User B's customers, orders, or measurements
- Security rules enforce this at the database level

## Implementation Details

### Repositories

All repositories follow the same pattern:

1. **CustomersFirestoreRepository**
   - Path: `users/{uid}/customers`
   - All CRUD operations use `_getCollectionPath()` which returns user-scoped path

2. **OrdersFirestoreRepository**
   - Path: `users/{uid}/orders`
   - All CRUD operations use `_getCollectionPath()` which returns user-scoped path

3. **MeasurementsFirestoreRepository**
   - Path: `users/{uid}/measurements`
   - All CRUD operations use `_getCollectionPath()` which returns user-scoped path

4. **ProfileFirestoreRepository**
   - Path: `users/{uid}` (document, not subcollection)
   - Uses `_getUserPath()` which returns user-scoped path

### Security Rules

The `firestore.rules` file enforces isolation:

```javascript
match /users/{userId} {
  allow read, write: if isOwner(userId);
  
  match /customers/{customerId} {
    allow read, write: if isOwner(userId);
  }
  
  match /orders/{orderId} {
    allow read, write: if isOwner(userId);
  }
  
  match /measurements/{measurementId} {
    allow read, write: if isOwner(userId);
  }
}
```

The `isOwner(userId)` function ensures:
- User is authenticated (`request.auth != null`)
- The authenticated user's UID matches the path's `{userId}`

### Logout Behavior

The `AuthRepository.signOut()` method:
- Signs out from Firebase Auth
- Clears local secure storage
- **Does NOT delete Firestore data**

This is correct because:
- Data should persist across sessions
- Users expect to see their data when they log back in
- Data is already isolated by UID, so there's no security risk

## Verification Checklist

✅ All repositories use `users/{uid}/...` paths
✅ All operations use `FirebaseAuth.instance.currentUser.uid`
✅ No root-level collections are used
✅ Security rules enforce user isolation
✅ Logout only clears local storage, not Firestore data
✅ All queries are scoped to the authenticated user's UID
✅ Streams are scoped to the authenticated user's UID

## Testing Multi-User Isolation

To verify isolation works correctly:

1. Create User A account and add customers/orders
2. Logout from User A
3. Create User B account and add customers/orders
4. Verify User B only sees their own data
5. Logout from User B
6. Login as User A again
7. Verify User A sees their original data (data persisted)

## Important Notes

- **Data persistence is intentional**: Data remaining in Firestore after logout is the correct behavior
- **No data leakage**: Security rules prevent users from accessing other users' data
- **UID-based isolation**: All data is tied to the user's Firebase Auth UID
- **No manual cleanup needed**: Firestore data persists automatically and is isolated by UID

