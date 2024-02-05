/*

Cleaning Data in SQL Queries

*/


Select *
From PORTFOLIO..Nashvillehousing 

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDateConverted, CONVERT(Date,SaleDate)
From PORTFOLIO..Nashvillehousing 


Update PORTFOLIO..Nashvillehousing 
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update PORTFOLIO..Nashvillehousing 
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address dataSelect 

Select PropertyAddress 
From PORTFOLIO..Nashvillehousing 

Select a.ParcelID , a.PropertyAddress , b.ParcelID ,b.PropertyAddress,ISNULL ( a.PropertyAddress,b.PropertyAddress)
From PORTFOLIO..Nashvillehousing a
JOIN PORTFOLIO..Nashvillehousing b
	on a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress  is null

UPDATE a
SET PropertyAddress = ISNULL ( a.PropertyAddress,b.PropertyAddress)
From PORTFOLIO..Nashvillehousing a
JOIN PORTFOLIO..Nashvillehousing b
	on a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
From PORTFOLIO..Nashvillehousing

ALTER TABLE PORTFOLIO..Nashvillehousing 
Add StreetAdd Nvarchar(225);

Update PORTFOLIO..Nashvillehousing 
SET StreetAdd = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PORTFOLIO..Nashvillehousing
Add CITYADD Nvarchar(225);

Update PORTFOLIO..Nashvillehousing 
SET CITYADD = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--................ANOTHER METHOD AND ITS EASY......

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PORTFOLIO..Nashvillehousing 


ALTER TABLE  PORTFOLIO..Nashvillehousing 
Add OwnerSplitAddress Nvarchar(255);

Update  PORTFOLIO..Nashvillehousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE  PORTFOLIO..Nashvillehousing 
Add OwnerSplitCity Nvarchar(255);

Update  PORTFOLIO..Nashvillehousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE  PORTFOLIO..Nashvillehousing 
Add OwnerSplitState Nvarchar(255);

Update  PORTFOLIO..Nashvillehousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) 

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
From PORTFOLIO..Nashvillehousing 
Group by SoldAsVacant 
Order by 2

Select SoldAsVacant
,CASE When SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
From PORTFOLIO..Nashvillehousing 

UPDATE PORTFOLIO..Nashvillehousing 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PORTFOLIO..NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PORTFOLIO..Nashvillehousing 




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PORTFOLIO..Nashvillehousing 


ALTER TABLE PORTFOLIO..Nashvillehousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

