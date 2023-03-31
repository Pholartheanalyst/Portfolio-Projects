/*
DATA CLEANING OF HOUSING DATA USING SQL
*/

---prevew the data
select * 
from NashVille.dbo.NashVilleHousing$

----Change the date-time colum to just date using the CONVERT() function and UPDATE() the table
----The UPDATE didn't work on the existing SaleDate column, so I created a new column called SalesDates using ALTER
ALTER TABLE NashVilleHousing$
ADD SalesDate Date

UPDATE NashVilleHousing$
SET SalesDate = CONVERT(Date, SaleDate)


----Fill in the NULLs in the property address column
----The best way to handle nulls is to investigate if the column with null values has a relationship with the other columns
----This can give us an insight into how to handle the nulls
----If we just get rid of the nulls, we can be loosing alot of data and our analysis will not be accurate
----In this case of the address, we can check if 2 or more properties belong to the same owner or if they have the same ParcelID.
----To be able to check against each other, a self join is the best way
UPDATE fir
SET PropertyAddress = ISNULL(fir.PropertyAddress, sec.PropertyAddress)
FROM NashVille..NashVilleHousing$ fir
JOIN NashVille..NashVilleHousing$ sec
	on fir.ParcelID = sec.ParcelID
	AND fir.[UniqueID ] <> sec.[UniqueID ]
WHERE fir.PropertyAddress is null

----The same process applies to the owner name
UPDATE fir
SET OwnerName = ISNULL(fir.OwnerName, sec.OwnerName)
FROM NashVille..NashVilleHousing$ fir
JOIN NashVille..NashVilleHousing$ sec
	--on fir.OwnerName = sec.OwnerName
	on fir.ParcelID = sec.ParcelID
	AND fir.[UniqueID ] <> sec.[UniqueID ]
WHERE fir.OwnerName is null


-----In a similar manar again, I will update ownerAddress
---As observed from the data, properties with the same ParcelID, have the same  propertyAddress, OwnerName and in the real sense ownerAddress should be same
UPDATE fir
SET OwnerAddress = ISNULL(fir.OwnerAddress, sec.OwnerAddress)
FROM NashVille..NashVilleHousing$ fir
JOIN NashVille..NashVilleHousing$ sec
	on fir.OwnerName = sec.OwnerName
	--on fir.ParcelID = sec.ParcelID
	AND fir.PropertyAddress = sec.PropertyAddress
WHERE fir.OwnerAddress is null


----For observations where I don not have the Owner name to populate the Owner Address or vice versa in the self join
----Or have the property address and parcelID in the self join
----I will remove the rows


----The PropertyAddress and OwnerAddress columns contain both Addresses and Cities, so I will split into two columns
----First Create 2 columns in the table (Address and City), then update by doing a SUBSTRING of the combined addres
----The CHARINDEX() helps to identify where the split should happen by indicating a delimiter
ALTER TABLE NashVilleHousing$
ADD PptyAddress nvarchar(255)

UPDATE NashVilleHousing$
SET PptyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashVilleHousing$
ADD PptyCity nvarchar(255)

UPDATE NashVilleHousing$
SET PptyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))



--ALTER TABLE NashVilleHousing$
--DROP COLUMN LandlordCity

----Creating columns for the owner's address and city
ALTER TABLE NashVilleHousing$
ADD LandlordAddress nvarchar(255)

---Here, I used the PARSENAME() and REPLACE() functions for the owners address splitting, which gives same result as the SUBSTRING()
UPDATE NashVilleHousing$
SET LandlordAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashVilleHousing$
ADD LandlordCity nvarchar(255)

UPDATE NashVilleHousing$
SET LandlordCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


ALTER TABLE NashVilleHousing$
ADD LandlordState nvarchar(255)

UPDATE NashVilleHousing$
SET LandlordState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)



---Next, I used the CASE statement to update the Yes and No columns
UPDATE NashVilleHousing$
SET SoldAsVacant =
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM NashVille..NashVilleHousing$


----Removing duplicates using the CTE method
WITH DupCTE AS(
	SELECT *, 
         ROW_NUMBER() OVER(
		 PARTITION BY ParcelID, 
					 PropertyAddress, 
					 SalesDate,
					 SalePrice,
					 LegalReference,
					 OwnerName
           ORDER BY UniqueID) AS DuplicateCount
    FROM NashVille..NashVilleHousing$)
DELETE FROM DupCTE
WHERE DuplicateCount > 1;


----Removing Unused Columns
ALTER TABLE NashVilleHousing$
DROP COLUMN PropertyAddress, SaleDate,OwnerAddress,TaxDistrict



---Re-ordering the columns 
SELECT [UniqueID ], ParcelID, LandUse, SalesDate, SalePrice, LegalReference, SoldAsVacant, Acreage,LandValue, BuildingValue, TotalValue, YearBuilt,Bedrooms,FullBath,HalfBath, PptyAddress, PptyCity, OwnerName, LandlordAddress, LandlordCity, LandlordState
FROM NashVille..NashVilleHousing$



