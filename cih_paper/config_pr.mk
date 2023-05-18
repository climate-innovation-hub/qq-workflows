# Quantile delta mapping configuration

## User configured variables

METHOD=qdm
SCALING=multiplicative
OUTPUT_UNITS="mm day-1"
SSR=--ssr

OBS_DATASET=AGCD
TARGET_VAR=precip
TARGET_UNITS_ORIG="mm day-1"
TARGET_START=1990
TARGET_END=2019

MODEL=ACCESS-ESM1-5
EXPERIMENT=ssp370
RUN=r1i1p1f1
MODEL_GRID=gn
NCI_LOC=fs38/publications

HIST_VAR=pr
HIST_UNITS_ORIG="kg m-2 s-1"
HIST_VERSION=v20191115
HIST_START=1995
HIST_END=2014

REF_VAR=pr
REF_UNITS_ORIG="kg m-2 s-1"
REF_VERSION=v20191115
REF_START=2056
REF_END=2085

# (Townsville)
EXAMPLE_LAT = -19.26
EXAMPLE_LON = 146.8
EXAMPLE_MONTH = 5


## Automatic variables

HIST_FILES_ORIG := $(sort $(wildcard /g/data/${NCI_LOC}/CMIP6/CMIP/*/${MODEL}/historical/${RUN}/day/${HIST_VAR}/${MODEL_GRID}/${HIST_VERSION}/*.nc))
REF_FILES_ORIG := $(sort $(wildcard /g/data/${NCI_LOC}/CMIP6/ScenarioMIP/*/${MODEL}/${EXPERIMENT}/${RUN}/day/${REF_VAR}/${MODEL_GRID}/${REF_VERSION}/*.nc))
TARGET_FILES_ORIG := $(wildcard /g/data/xv83/agcd-csiro/${TARGET_VAR}/daily/*_AGCD-CSIRO_r005_*_daily_space-chunked.zarr)

OUTPUT_HIST_DIR=/g/data/wp00/data/QQ-CMIP6/${MODEL}/historical/${RUN}/day/${HIST_VAR}/${HIST_VERSION}
OUTPUT_REF_DIR=/g/data/wp00/data/QQ-CMIP6/${MODEL}/${EXPERIMENT}/${RUN}/day/${REF_VAR}/${REF_VERSION}
OUTPUT_TARGET_DIR=/g/data/wp00/data/${OBS_DATASET}
ifeq (${SSR}, --ssr)
HIST_DATA=${OUTPUT_HIST_DIR}/${HIST_VAR}-ssr_day_${MODEL}_historical_${RUN}_${MODEL_GRID}_${HIST_START}0101-${HIST_END}1231.nc
HIST_UNITS=${OUTPUT_UNITS}
REF_DATA=${OUTPUT_REF_DIR}/${REF_VAR}-ssr_day_${MODEL}_${EXPERIMENT}_${RUN}_${MODEL_GRID}_${REF_START}0101-${REF_END}1231.nc
REF_UNITS=${OUTPUT_UNITS}
REF_FNAME_VAR=${REF_VAR}-ssr
TARGET_DATA=${OUTPUT_TARGET_DIR}/${TARGET_VAR}-ssr_${OBS_DATASET}_r005_${TARGET_START}0101-${TARGET_END}1231_daily.nc
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

AF_FILE=${REF_FNAME_VAR}-${METHOD}-${SCALING}-monthly-adjustment-factors_${MODEL}_${EXPERIMENT}_${RUN}_${MODEL_GRID}_${REF_START}0101-${REF_END}1231_wrt_${HIST_START}0101-${HIST_END}1231.nc
AF_PATH=${OUTPUT_REF_DIR}/${AF_FILE}

QQ_BASE=${REF_FNAME_VAR}_day_${MODEL}_${EXPERIMENT}_${RUN}_AUS-r005_${REF_START}0101-${REF_END}1231_${METHOD}-${SCALING}-monthly_${OBS_DATASET}_${TARGET_START}0101-${TARGET_END}1231_historical_${HIST_START}0101-${HIST_END}1231
QQ_PATH=${OUTPUT_REF_DIR}/${QQ_BASE}.nc

VALIDATION_NOTEBOOK=${OUTPUT_REF_DIR}/${QQ_BASE}.ipynb

QQ_MEAN_MATCH_PATH=${OUTPUT_REF_DIR}/${QQ_BASE}_mean-match.nc





