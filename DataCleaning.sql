--Explore the Data

Select SaleDateConverted
From DataCleaning.dbo.NashvilleHousing

------------------------------------------------------------------------

--Standardize Data Format

Select SaleDate, Convert(date, SaleDate)
FROM DataCleaning.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = Convert(date, SaleDate)
--the query should Update the information in the data

Alter Table NashvilleHousing
ADD SaleDateConverted Date;
--Another way to update the information if the above query did not return
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-------------------------------------------------------------------------------------------------

--Populate Property Address Data

Select ParcelID,PropertyAddress
From DataCleaning.dbo.NashvilleHousing

Select *
From DataCleaning.dbo.NashvilleHousing
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From DataCleaning.dbo.NashvilleHousing a 
Join DataCleaning.dbo.NashvilleHousing b 
	On a.ParcelID = b. ParcelID
	AND a.[UniqueID ] = b. [UniqueID ]
Where a.PropertyAddress is Null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IsNull(a.PropertyAddress, b.PropertyAddress)
From DataCleaning.dbo.NashvilleHousing a 
Join DataCleaning.dbo.NashvilleHousing b 
	On a.ParcelID = b. ParcelID
	AND a.[UniqueID ] = b. [UniqueID ]
Where a.PropertyAddress is Null 


UPDATE a
SET PropertyAddress = IsNull(a.PropertyAddress, b.PropertyAddress)
From DataCleaning.dbo.NashvilleHousing a
Join DataCleaning.dbo.NashvilleHousing b
	ON a.ParcelID = b. ParcelID
	AND a.[UniqueID ] <> b. [UniqueID ]
Where a.PropertyAddress is Null


---------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns(Address, City, and State)


Select
	Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
From DataCleaning.dbo.NashvilleHousing


Select
	Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1)  AS Address, 
	Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
From DataCleaning.dbo.NashvilleHousing


--1) 
Alter Table DataCleaning.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar (255);

UPDATE DataCleaning.dbo.NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CharIndex(',', PropertyAddress) - 1)
--2)
Alter Table DataCleaning.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar (255); 

UPDATE DataCleaning.dbo.NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, CharIndex(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From DataCleaning.dbo.NashvilleHousing


--1)
Alter Table DataCleaning.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar (255);

UPDATE DataCleaning.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

--2)
Alter Table DataCleaning.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar (255);

UPDATE DataCleaning.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

--3)
Alter Table DataCleaning.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar (255);

UPDATE DataCleaning.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

------------------------------------------------------------------------------------------------------

--Changing Y and N to YES and NO in "SoldAsVacant" Field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From DataCleaning.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From DataCleaning.dbo.NashvilleHousing

UPDATE DataCleaning.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
	
-------------------------------------------------------------------------------------

--Remove Duplicates

With RowNumCTE AS (
	Select *,
		ROW_NUMBER() Over(
		Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by 
				UniqueID 
				) row_num


From DataCleaning.dbo.NashvilleHousing
)

DELETE
From RowNumCTE
WHERE row_num > 1 
--Order by 2

------------------------------------------------------------------------------------------------------------------------


--Delete Unused Columns

Alter Table DataCleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
