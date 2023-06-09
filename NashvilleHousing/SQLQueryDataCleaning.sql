Select *
from NashvilleHousing

-- Standardize Date Format

select saledateconverted, convert (Date,SaleDate)
from NashvilleHousing


Update NashvilleHousing
Set SaleDate = convert(date,Saledate) 

Alter table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = convert(date,Saledate) 


-- Populate Property Addres data
Select *
From NashvilleHousing
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
	

Update a
Set PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- using substring to breaking out address into individual columns
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , Len(PropertyAddress))  as Address


From NashvilleHousing

Alter table NashvilleHousing
add PropertySplitAddress  Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )

Alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , Len(PropertyAddress))

select*
from NashvilleHousing

-- Using Parsename to break down the address into individual columns
-- Parsename method works on "." only, so replace "," to "." first

select OwnerAddress
from NashvilleHousing

Select
PARSENAME (REPLACE(OwnerAddress,',','.'), 3) as Address ,
PARSENAME (REPLACE(OwnerAddress,',','.'), 2) as City ,
PARSENAME (REPLACE(OwnerAddress,',','.'), 1) as State
From NashvilleHousing


Alter table NashvilleHousing
add OwnerSplitAddress  Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress,',','.'), 3)

Alter table NashvilleHousing
add OwnersplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnersplitCity =  PARSENAME (REPLACE(OwnerAddress,',','.'), 2) 


Alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState= PARSENAME (REPLACE(OwnerAddress,',','.'), 1) 

Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant 
, CASE When SoldasVacant = 'Y' THEN 'Yes'
	   When SoldasVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
       END
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldasVacant = 'Y' THEN 'Yes'
	   When SoldasVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
       END


--Remove Duplicates
WITH RowNumCTE AS (
Select * , 
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From NashvilleHousing
)

Select *
From RowNumCTE
where row_num >1
ORder by PropertyAddress


-- Delete Unused Columns

Alter table NashvilleHousing
Drop Column SaleDate, OwnerAddress, TaxDistrict, PropertyAddress