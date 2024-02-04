-- Cleaning Data in SQL Queries
SELECT *
FROM PortfolioProject.NashvilleHousingData;

-- Change Date Format
SELECT SaleDate, STR_TO_DATE(SaleDate, '%m/%d/%Y') AS ConvertedDate
FROM PortfolioProject.NashvilleHousingData;

UPDATE PortfolioProject.NashvilleHousingData
SET SaleDate = STR_TO_DATE(SaleDate, '%m/%d/%Y');

-- Populate Property Address Data
Select *
FROM PortfolioProject.NashvilleHousingData
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(b.PropertyAddress, a.PropertyAddress)
FROM PortfolioProject.NashvilleHousingData a
JOIN PortfolioProject.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL or a.PropertyAddress = '';

UPDATE PortfolioProject.NashvilleHousingData a
JOIN PortfolioProject.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE(b.PropertyAddress, a.PropertyAddress)
WHERE a.PropertyAddress is NULL or a.PropertyAddress = '';

-- Putting Addresses into individual columns
SELECT PropertyAddress
FROM PortfolioProject.NashvilleHousingData;

SELECT 
    SUBSTRING_INDEX(PropertyAddress, ',', 1) as Address,
    SUBSTRING_INDEX(PropertyAddress, ',', -1) as Address
FROM PortfolioProject.NashvilleHousingData;


ALTER TABLE PortfolioProject.NashvilleHousingData
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject.NashvilleHousingData
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);

ALTER TABLE PortfolioProject.NashvilleHousingData
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.NashvilleHousingData
SET PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1);

SELECT OwnerAddress
FROM PortfolioProject.NashvilleHousingData;

SELECT
	SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3), '.', 1),
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1),
    SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1)
FROM PortfolioProject.NashvilleHousingData;

ALTER TABLE PortfolioProject.NashvilleHousingData
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject.NashvilleHousingData
SET OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3), '.', 1);

ALTER TABLE PortfolioProject.NashvilleHousingData
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject.NashvilleHousingData
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1);

ALTER TABLE PortfolioProject.NashvilleHousingData
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.NashvilleHousingData
SET OwnerSplitState = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1);

-- Change Y and N to Yes and No in SoldAsVacant
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2; 

SELECT 
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS SoldAsVacant
FROM PortfolioProject.NashvilleHousingData;

UPDATE PortfolioProject.NashvilleHousingData
SET SoldAsVacant = CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;
    
-- Remove Duplicates
WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID,
                            PropertyAddress, -- Corrected column name
                            SalePrice,
                            SaleDate,
                            LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM PortfolioProject.NashvilleHousingData
)
DELETE FROM PortfolioProject.NashvilleHousingData
WHERE (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference) IN (
    SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    FROM RowNumCTE
    WHERE row_num > 1
);

-- Delete Unused Columns
ALTER TABLE PortfolioProject.NashvilleHousingData
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;

SELECT *
FROM PortfolioProject.NashvilleHousingData;