/*

Cleaning Data in SQL Queries

*/

select *
from PortfolioProject.dbo.NashvilleHousing


-- Standardize Date Format

select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address Date

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
--where a.PropertyAddress is null


update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- breaking out Address into Indiviual columns(address, city, state)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select
SUBSTRING(propertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1) as Address,      
--CHARINDEX(',',PropertyAddress)    
SUBSTRING(propertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(propertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE portfolioproject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
Update portfolioproject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1) 


ALTER TABLE portfolioproject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);
Update portfolioproject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(propertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing


select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3) as address,
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2) as city,
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1) as state
from PortfolioProject.dbo.NashvilleHousing
where OwnerAddress is not null


ALTER TABLE portfolioproject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
Update portfolioproject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3) 


ALTER TABLE portfolioproject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
Update portfolioproject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE portfolioproject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);
Update portfolioproject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


select *
from PortfolioProject.dbo.NashvilleHousing


-- change Y and N to Yes and No in 'sold as vacant' field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
order by 2

select SoldAsVacant
,CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		END
from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		END


-- romove duplicate

WITH RowNumCTE as(
select *,
    ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by
				UniqueID
				)row_num
from PortfolioProject.dbo.NashvilleHousing
--order by Parcelid
)
select *
from RowNumCTE
where row_num > 1
order by propertyaddress

