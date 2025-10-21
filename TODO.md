# CRUD Operations Fixes for Champs and Parcelles

## Issues Identified
- Duplicate provider files (field_provider.dart vs champ_parcelle_provider.dart)
- Redundant usecases duplicating provider functionality
- Inconsistent API endpoint usage
- Auth flow issues with OTP verification

## Tasks to Complete

### 1. Remove Duplicate Provider
- [ ] Delete `field_provider.dart` (keep `champ_parcelle_provider.dart`)

### 2. Remove Redundant Usecases
- [ ] Delete `fetch_champs.dart`
- [ ] Delete `fetch_parcelles.dart`
- [ ] Delete `create_champ.dart`

### 3. Update Imports and References
- [ ] Update all files importing from removed providers/usecases
- [ ] Ensure all references point to `champ_parcelle_provider.dart`

### 4. Fix Auth Flow Issues
- [ ] Complete OTP page updates for userId handling
- [ ] Ensure proper type consistency in auth repository

### 5. Verify Implementation
- [ ] Test that all CRUD operations work correctly
- [ ] Ensure no broken imports or references remain
