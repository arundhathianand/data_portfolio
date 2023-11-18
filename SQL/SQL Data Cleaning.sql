
SELECT * FROM NashvilleHousing

-- Standardise Date Column

SELECT SaleDate, STR_TO_DATE(SaleDate, '%M %e, %Y') FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = STR_TO_DATE(SaleDate, '%M %e, %Y')

-- Clean Property Address Column 

SELECT * FROM NashvilleHousing
order by ParcelID 

SELECT NH_A.ParcelID, NH_A.PropertyAddress, NH_B.ParcelID, NH_B.PropertyAddress, IF(NH_A.PropertyAddress = '', 'Y', 'N')
FROM NashvilleHousing NH_A
JOIN NashvilleHousing NH_B
	ON NH_A.ParcelID = NH_B.ParcelID AND NH_A.UniqueID <> NH_B.UniqueID
WHERE NH_A.PropertyAddress = ''

-- Self-join and assign missing PropertyAddress based on matching ParcelID

UPDATE NashvilleHousing NH_A 
JOIN NashvilleHousing NH_B
	ON NH_A.ParcelID = NH_B.ParcelID AND NH_A.UniqueID <> NH_B.UniqueID
SET NH_A.PropertyAddress = IF(NH_A.PropertyAddress = '', NH_B.PropertyAddress, NH_A.PropertyAddress)
WHERE NH_A.PropertyAddress = ''

-- Breaking Property Address into Address, City and STATE

SELECT 
SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address,
SUBSTRING_INDEX(PropertyAddress, ',', -1) AS City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress text;

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity text;

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1)

-- Breaking Owner Address into Address, City and STATE

SELECT OwnerAddress FROM NashvilleHousing

SELECT 
SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OAddress,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS OCity,
SUBSTRING_INDEX(OwnerAddress, ',', -1) AS OState
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress text;

UPDATE NashvilleHousing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity text;

UPDATE NashvilleHousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState text;

UPDATE NashvilleHousing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1)

-- Standardise SoldAsVacant column entries 

 SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) FROM NashvilleHousing
 GROUP BY SoldAsVacant
 
 SELECT SoldAsVacant,
 	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
 		 WHEN SoldAsVacant = 'N' THEN 'No'
 		 ELSE SoldAsVacant
		 END
 FROM NashvilleHousing
 
 UPDATE NashvilleHousing
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
 		 WHEN SoldAsVacant = 'N' THEN 'No'
 		 ELSE SoldAsVacant
		 END
		 
-- Check for duplicates

With ABC AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM NashvilleHousing
)
SELECT UniqueID from ABC WHERE row_num >1

-- Remove Duplicates

DELETE FROM NashvilleHousing
WHERE UniqueID in (
	SELECT UniqueID from (
		SELECT UniqueID,
			   ROW_NUMBER() OVER (
					PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
		FROM NashvilleHousing
		) dummy
	WHERE row_num >1
)

-- Remove useless columns

ALTER TABLE NashvilleHousing
	DROP OwnerAddress,
	DROP PropertyAddress,
	DROP  TaxDistrict
	
ALTER TABLE NashvilleHousing
	DROP SaleDate
	

