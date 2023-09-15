/*

Cleaning Data in SQL Queries

*/

SELECT * 
FROM dbo.NashvilleHousing


----------------------------------------------------------

--Standardize date format

SELECT SaleDateConverted, CONVERT(Date,SaleDate) 
FROM dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
ON a.parcelID = b.parcelID
AND a.[UniqueID] != b.[UniqueID]
WHERE a.propertyaddress IS NULL


UPDATE a
SET propertyAddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
ON a.parcelID = b.parcelID
AND a.[UniqueID] != b.[UniqueID]
WHERE a.propertyaddress IS NULL


--------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM dbo.nashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress)) AS Address

FROM dbo.nashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM dbo.nashvilleHousing


SELECT OwnerAddress
FROM dbo.nashvilleHousing

SELECT 
PARSENAME(REPLACE (OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE (OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE (OwnerAddress, ',', '.') ,1)
FROM dbo.nashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE (OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE (OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE (OwnerAddress, ',', '.') ,1)


----------------------------------------------------------------------

-- Change Y And N as Yes and No in "Sold as Vacant" field

SELECT DISTINCT(Soldasvacant), COUNT(Soldasvacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT Soldasvacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldASVacant
	   END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldASVacant
	   END



--------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
SELECT * ,
      ROW_NUMBER() OVER (
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY
				     UniqueID
				     ) row_num
       
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE Row_num > 1
--ORDER BY PropertyAddress



-------------------------------------------------------

-- Delete Unused Columns


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
