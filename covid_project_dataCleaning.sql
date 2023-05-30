SELECT *
FROM nashville_housing;

-- 1. Standardize Date Format :
SELECT SaleDate, convert(SaleDate, DATE) AS sale_date
FROM nashville_housing;

SET sql_safe_updates = 0;

ALTER TABLE nashville_housing
ADD saleDateConverted DATE;
UPDATE nashville_housing
SET saleDateConverted = convert(SaleDate, DATE);


-- 2. Populate property address data :
SELECT propertyaddress
FROM nashville_housing
WHERE propertyaddress = '' OR propertyaddress IS NULL;

SELECT 	a.parcelid, a.propertyaddress,
		b.parcelid, b.propertyaddress,
		IF (a.propertyaddress = '', b.propertyaddress, a.propertyaddress)
FROM nashville_housing AS a
JOIN nashville_housing AS b
ON a.parcelID = b.parcelid AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress = '' OR a.propertyaddress IS NULL;

/*
UPDATE a
SET propertyaddress = IF (a.propertyaddress = '', b.propertyaddress, a.propertyaddress)
FROM nashville_housing AS a
JOIN nashville_housing AS b
ON a.parcelID = b.parcelid AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress = '' OR a.propertyaddress IS NULL;
-- this query occurs error.
*/

UPDATE nashville_housing AS a
JOIN nashville_housing AS b
ON a.parcelID = b.parcelid AND a.uniqueid <> b.uniqueid
SET a.propertyaddress = IF (a.propertyaddress = '', b.propertyaddress, a.propertyaddress)
WHERE a.propertyaddress = '' OR a.propertyaddress IS NULL;


-- 3. Break out address into columns(add, city, state) :
SELECT	substring(propertyaddress, 1, locate(',', propertyaddress) - 1) AS address,
		substring(propertyaddress, locate(',', propertyaddress) + 1, length(propertyaddress))
        AS city
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD address_1 VARCHAR(255);
UPDATE nashville_housing
SET address_1 = substring(propertyaddress, 1, locate(',', propertyaddress) - 1);

ALTER TABLE nashville_housing
ADD address_2 VARCHAR(255);
UPDATE nashville_housing
SET address_2 = substring(propertyaddress, locate(',', propertyaddress) + 1, length(propertyaddress));


SELECT 	owneraddress,
		substring_index(owneraddress, ',', 1) AS owner_street,
        substring_index(substring_index(owneraddress, ',', 2), ',', -1) AS owner_city,
        substring_index(owneraddress, ',', -1) AS owner_state        
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD	owner_street VARCHAR(255);
UPDATE nashville_housing
SET owner_street = substring_index(owneraddress, ',', 1);

ALTER TABLE nashville_housing
ADD	owner_city VARCHAR(255);
UPDATE nashville_housing
SET owner_city = substring_index(substring_index(owneraddress, ',', 2), ',', -1);

ALTER TABLE nashville_housing
ADD	owner_state VARCHAR(255);
UPDATE nashville_housing
SET owner_state = substring_index(owneraddress, ',', -1);


-- 4. Change Y/N to Yes/No in SoldAsVacant column :
SELECT DISTINCT(soldasvacant)
FROM nashville_housing;

SELECT soldasvacant,
CASE
	WHEN soldasvacant = 'Y' THEN 'YES'
    WHEN soldasvacant = 'N' THEN 'NO'
    ELSE soldasvacant
END
FROM nashville_housing;

UPDATE nashville_housing
SET soldasvacant = 	CASE
						WHEN soldasvacant = 'Y' THEN 'YES'
						WHEN soldasvacant = 'N' THEN 'NO'
						ELSE soldasvacant
					END;


-- 5. Remove duplicates :
WITH row_num_cte AS(
SELECT *,
ROW_NUMBER() over (
PARTITION BY	ParcelID, PropertyAddress,
				SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) AS row_num
FROM nashville_housing)
DELETE FROM row_num_cte
WHERE row_num > 1;
-- This code is not working in MySQL because CTE is not recognised as a table.


-- 6. Delete unused columns :
ALTER TABLE nashville_housing
DROP COLUMN SaleDate;

SELECT * FROM nashville_housing;

