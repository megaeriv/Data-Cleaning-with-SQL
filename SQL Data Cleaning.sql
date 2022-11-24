select *
From PortfolioProject.DBO.NashvilleHousing 

--Standardizing date format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(date, saledate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date, saledate)




----------------------------------------------------------------------------------------------------------





--Property Address Data
--- populate empty property address with already recorded PacrelID

Select *
From NashvilleHousing
Order by ParcelID

Select a.ParcelID, a. PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--updating property address
Update a
Set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]




------------------------------------------------------------------------------------------------------------------





--Splitting address information into individual columns for property adress (address, city) and owner adress(Address, City, State)

Select * 
From NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From NashvilleHousing

-----Create new columns for property address and city-----
Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity  = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

---owner address----------

Select OwnerAddress
From NashvilleHousing

-- using PARSENAME, it extracts backwards


Select
PARSENAME(Replace(OwnerAddress, ',', '.') ,1) as OwnerState,
PARSENAME(Replace(OwnerAddress, ',', '.') ,2) as OwnerCity, 
PARSENAME(Replace(OwnerAddress, ',', '.') ,3) as OwnerAddress
From NashvilleHousing


--Updating table
Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') ,3) 

Alter Table NashvilleHousing
Add OwnerCity Nvarchar(255);

Update NashvilleHousing
Set OwnerCity  = PARSENAME(Replace(OwnerAddress, ',', '.') ,2) 

Alter Table NashvilleHousing
Add OwnerState Nvarchar(255);

Update NashvilleHousing
Set OwnerState  = PARSENAME(Replace(OwnerAddress, ',', '.') ,1) 




----------------------------------------------------------------------------------------------------------


--Changeing Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2



select SoldAsVacant,
	CASE 
		When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
From NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = CASE 
		When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END




-------------------------------------------------------------------------------------------------------------------------------


--Remove Duplicates 


WITH RowNumCTE AS(
select *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID, 
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 Order by
						UniqueID
						) row_num

From NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

----Query above show duplicate, with row_num showing number of duplicates. Next step is to delete

WITH RowNumCTE AS(
select *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID, 
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 Order by
						UniqueID
						) row_num

from NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1



--------------------------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused columns (not usually done for raw data)

Select *
From NashvilleHousing 

ALTER TABLE NashvilleHousing 
Drop  Column OwnerAddress, TaxDistrict, PropertyAddress



