# Equi-distant/ratio CDF mapping configuration

## User configured variables

METHOD=ecdfm
SCALING=additive
OUTPUT_UNITS=C
#SSR=--ssr

OBS_DATASET=AGCD
MODEL=ACCESS-ESM1-5
EXPERIMENT=ssp370

HIST_VAR=tasmin
HIST_UNITS_ORIG=K
HIST_START=1980
HIST_END=1999

REF_VAR=tmin
REF_UNITS_ORIG=C
REF_START=1980
REF_END=1999

TARGET_VAR=tasmin
TARGET_UNITS_ORIG=K
TARGET_START=2000
TARGET_END=2019

# (Omeo)
EXAMPLE_LAT = -37.1
EXAMPLE_LON = 147.6
EXAMPLE_MONTH = 5

## Automatic variables
HIST_PATH=/g/data/tp28/ACS_DRS_v1_AWAP/CSIRO-BOM-ACCESS-CM2/historical/r4i1p1f1/BOM-BARPA-R/v1/day/${HIST_VAR}
EXP_PATH=/g/data/tp28/ACS_DRS_v1_AWAP/CSIRO-BOM-ACCESS-CM2/${EXPERIMENT}/r4i1p1f1/BOM-BARPA-R/v1/day/${HIST_VAR}

HIST_FILES_ORIG := $(sort $(wildcard ${HIST_PATH}/*day_198*.nc) $(wildcard ${HIST_PATH}/*day_199*.nc))
TARGET_FILES_ORIG := $(sort $(wildcard ${HIST_PATH}/*day_200*.nc) $(wildcard ${HIST_PATH}/*day_201*.nc) $(wildcard ${EXP_PATH}/*day_201*.nc))
REF_FILES_ORIG := $(sort $(wildcard /g/data/zv2/agcd/v1/${REF_VAR}/mean/r005/01day/*198*.nc) $(wildcard /g/data/zv2/agcd/v1/${REF_VAR}/mean/r005/01day/*199*.nc))
#REF_FILES_ORIG := $(wildcard /g/data/xv83/agcd-csiro/${REF_VAR}/daily/*_AGCD-CSIRO_r005_*_daily_space-chunked.zarr)

OUTPUT_HIST_DIR=/g/data/wp00/users/dbi599/npcp
OUTPUT_REF_DIR=/g/data/wp00/users/dbi599/npcp
OUTPUT_TARGET_DIR=/g/data/wp00/users/dbi599/npcp
ifeq (${SSR}, --ssr)
HIST_DATA=${OUTPUT_HIST_DIR}/${HIST_VAR}-ssr_AUS-15_CSIRO-BOM-ACCESS-CM2_historical_r4i1p1f1_BOM-BARPA-R_v1_day_${HIST_START}01-${HIST_END}12_AWAP.nc
HIST_UNITS=${OUTPUT_UNITS}
REF_DATA=${OUTPUT_REF_DIR}/${REF_VAR}-ssr_${OBS_DATASET}_r005_${REF_START}0101-${REF_END}1231_daily.nc
REF_UNITS=${OUTPUT_UNITS}
REF_FNAME_VAR=${REF_VAR}-ssr
TARGET_DATA=${OUTPUT_HIST_DIR}/${HIST_VAR}-ssr_AUS-15_CSIRO-BOM-ACCESS-CM2_historical-${EXPERIMENT}_r4i1p1f1_BOM-BARPA-R_v1_day_${TARGET_START}01-${TARGET_END}12_AWAP.nc
TARGET_UNITS=${OUTPUT_UNITS}
TARGET_FNAME_VAR=${TARGET_VAR}-ssr
else
HIST_DATA=${HIST_FILES_ORIG}
HIST_UNITS=${HIST_UNITS_ORIG}
REF_DATA=${REF_FILES_ORIG}
REF_UNITS=${REF_UNITS_ORIG}
REF_FNAME_VAR=${REF_VAR}
TARGET_DATA=${TARGET_FILES_ORIG}
TARGET_UNITS=${TARGET_UNITS_ORIG}
TARGET_FNAME_VAR=${TARGET_VAR}
endif

AF_FILE=${REF_FNAME_VAR}-${METHOD}-${SCALING}-monthly-bias-vs-${OBS_DATASET}_AUS-15_CSIRO-BOM-ACCESS-CM2_historical_r4i1p1f1_BOM-BARPA-R_v1_day_${HIST_START}01-${HIST_END}12_AWAP.nc
AF_PATH=${OUTPUT_REF_DIR}/${AF_FILE}

QQ_BASE=${REF_FNAME_VAR}_AUS-15_CSIRO-BOM-ACCESS-CM2_historical-${EXPERIMENT}_r4i1p1f1_BOM-BARPA-R_v1_day_${TARGET_START}01-${TARGET_END}12_AWAP_${METHOD}-${SCALING}-monthly-${OBS_DATASET}-${HIST_START}0101-${HIST_END}1231
QQ_PATH=${OUTPUT_REF_DIR}/${QQ_BASE}.nc

VALIDATION_NOTEBOOK=${OUTPUT_REF_DIR}/${QQ_BASE}.ipynb


