--Project: SQL Data Cleaning

Select *
From PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------
-- *** Estandarizar el formato de la fecha, porque tiene el tiempo al final ***

Select SaleDate, Convert(Date, SaleDate)
From PortfolioProject..NashvilleHousing

--No funciona solo con update
Update NashvilleHousing
SET SaleDate = Convert(Date,SaleDate)

--Entonces agregamos una columna y agregamos allí la fecha
Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(Date,SaleDate)

Select SaleDate, SaleDateConverted
From PortfolioProject..NashvilleHousing

-----------------------------------------------------
-- *** Llenar los datos de Property Address ***
--La dirección de una propiedad no deberia ser null

Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null

--Hay muchos casos en la tabla donde el ParcelID es el mismo, y por ende la dirección de la propiedad también.
--Join de la misma tabla, para agregar la dirección donde parcel id sea igual
--isnull(lo que es null, lo que se agrega si es null)

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-----------------------------------------------------
-- *** Separar dirección en columnas individuales ***
-- Separar PropertyAddress en Address, City, State

--Address y city estan en PropertyAddress

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing


Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Select PropertySplitAddress
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select PropertySplitCity
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

--State esta en OwnerAddress
-- PARSENAME() para address, city y State

Select *
From PortfolioProject..NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing
 
Alter table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter table PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter table PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-----------------------------------------------------
-- *** Cambiar Y y N a Yers y No en la columna "SoldAsVacant" ***

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant =
Case When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End

-----------------------------------------------------
-- *** Eliminar Duplicados ***

-- Mostrar los duplicados con row_number()

With CTE_RowNum as(
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress, 
		 	 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by UniqueID) as row_num
From PortfolioProject..NashvilleHousing
--order by ParcelID
)
Delete
From CTE_rowNum
Where row_num > 1

--Select *
--From CTE_RowNum
--Where row_num > 1
--Order by PropertyAddress

-----------------------------------------------------
-- *** Eliminar Columnas no utilizadas ***

Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
DROP COLUMN TaxDistrict
