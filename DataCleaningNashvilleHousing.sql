
--DATA CLEANIING WITH SQL
 

SELECT *
FROM PortfolioProject..Sheet1$

--1 Coverting Date time to Date format

Alter Table Sheet1$
ADD ConvertedSaleDate Date

Update Sheet1$
SET ConvertedSaleDate = CONVERT(Date,SaleDate)


--2 Populate property address

SELECT *
FROM PortfolioProject..Sheet1$
--WHERE PropertyAddress is NULL
order by ParcelID

Select A.ParcelID , B.ParcelID ,	A.PropertyAddress, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProject..Sheet1$ A
JOIN PortfolioProject..Sheet1$ B
   ON A.ParcelID = B.ParcelID
   AND A.[UniqueID ]  <> B.[UniqueID ] 
WHERE A.PropertyAddress is NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProject..Sheet1$ A
JOIN PortfolioProject..Sheet1$ B
   ON A.ParcelID = B.ParcelID
   AND A.[UniqueID ]  <> B.[UniqueID ] 
WHERE A.PropertyAddress is NULL


--3 Breaking property address and owner address in seperate coloums

--SELECT PropertyAddress, substring(PropertyAddress,1, charindex(',', PropertyAddress)-1),
--SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1,LEN(PropertyAddress))
--FROM PortfolioProject..Sheet1$

Select PropertyAddress ,  Parsename(replace(PropertyAddress,',','.'),2)
,Parsename(replace(PropertyAddress,',','.'),1)
FROM PortfolioProject..Sheet1$

Alter table Sheet1$
Add PropertySplitCity nvarchar(255), PropertySplitAddress nvarchar(255)

update Sheet1$
SET PropertySplitCity =  Parsename(replace(PropertyAddress,',','.'),1),
PropertySplitAddress = Parsename(replace(PropertyAddress,',','.'),2)


Select OwnerAddress ,  Parsename(replace(	OwnerAddress,',','.'),3)
,Parsename(replace(OwnerAddress,',','.'),2),Parsename(replace(OwnerAddress,',','.'),1)
FROM PortfolioProject..Sheet1$

Alter table Sheet1$
Add OwnerSplitCity nvarchar(255), OwnerSplitAddress nvarchar(255), OwnerSplitState nvarchar(255)

update Sheet1$
SET OwnerSplitCity =  Parsename(replace(OwnerAddress,',','.'),2),
OwnerSplitAddress = Parsename(replace(OwnerAddress,',','.'),3),OwnerSplitState = Parsename(replace(OwnerAddress,',','.'),1)


select *
FROM PortfolioProject..Sheet1$



--4 Changing 'Y' and 'N' to 'Yes' and 'No' in Sold as vacant column

select Distinct(SoldAsVacant), count(SoldAsVacant)
FROM PortfolioProject..Sheet1$
group by SoldAsVacant

Select SoldAsVacant,
case when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N'THEN 'NO'
	 ELSE SoldAsVacant END
FROM PortfolioProject..Sheet1$
--where SoldAsVacant = 'N'

update Sheet1$
SET SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N'THEN 'NO'
	 ELSE SoldAsVacant END
FROM PortfolioProject..Sheet1$

select *
FROM PortfolioProject..Sheet1$
--where SoldAsVacant = 'Y'


--5 REMOVING DUPLICATES

WITH DUPLICATE AS(
select *, ROW_NUMBER() OVER 
         (PARTITION BY ParcelID, PropertyAddress, SaleDate , SalePrice , LegalReference
		 ORDER BY UniqueID) row_num
FROM PortfolioProject..Sheet1$
--ORDER BY ParcelID

)

DELETE
FROM DUPLICATE 
WHERE row_num>1

--SELECT *
--FROM DUPLICATE 
--WHERE row_num>1


 --DELETING COLOUMS THAT IS OF NO USE OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

 -------------------------------------------------------------------------------------------------------------
 --DATA EXPLORATION AND ANALYSIS FOR VISUALIZATION


 -- 1 Sale price of total property sold vs propertycity

 SELECT SUM(SalePrice), PropertySplitCity
 FROM PortfolioProject..Sheet1$
 Group by PropertySplitCity

-- 2 Sale price vs landuse vs NumberOfProperty

SELECT SUM(SalePrice) SalePricePerCity, LandUse ,count(LandUse) NumberOfProperty
FROM PortfolioProject..Sheet1$
Group by LandUse
order by NumberOfProperty desc

--3 month vs saleprice at partivular city

SELECT ConvertedSaleDate, SalePrice , PropertySplitCity
FROM PortfolioProject..Sheet1$
Order by ConvertedSaleDate
 