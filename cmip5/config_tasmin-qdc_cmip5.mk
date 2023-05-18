# Quantile delta change configuration
#
# Compare against: /g/data/wp00/data/QQ-CMIP5/CanESM2/tasmax/rcp85/2056-2085/tasmax_AUS_CanESM2_rcp85_r1i1p1_CSIRO-QQS-AGCD-1981-2010_day_wrt_1986-2005_2056-2085.nc
#
# /g/data/al33/replicas/CMIP5/combined/CCCma/CanESM2/rcp85/day/atmos/day/r1i1p1/v20120407/tasmax/tasmax_day_CanESM2_rcp85_r1i1p1_20060101-21001231.nc
#
# /g/data/al33/replicas/CMIP5/combined/CCCma/CanESM2/historical/day/atmos/day/r1i1p1/v20120410/tasmax/tasmax_day_CanESM2_historical_r1i1p1_19790101-20051231.nc


## User configured variables

METHOD=qdm
SCALING=additive
OUTPUT_UNITS=C
#SSR=--ssr
MEAN_MATCH_TIMESCALE=monthly

OBS_DATASET=AGCD
TARGET_VAR=tmin
TARGET_UNITS_ORIG=C
TARGET_START=1981
TARGET_END=2010

MODEL=CanESM2
EXPERIMENT=rcp85
RUN=r1i1p1
NCI_LOC=al33/replicas

HIST_VAR=tasmin
HIST_UNITS_ORIG=K
HIST_VERSION=v20120410
HIST_START=1986
HIST_END=2005

REF_VAR=tasmin
REF_UNITS_ORIG=K
REF_VERSION=v20120407
REF_START=2056
REF_END=2085

# (Hobart)
EXAMPLE_LAT = -42.9
EXAMPLE_LON = 147.3
EXAMPLE_MONTH = 5


## Automatic variables

HIST_FILES_ORIG := $(sort $(wildcard /g/data/${NCI_LOC}/CMIP5/combined/*/${MODEL}/historical/day/atmos/day/${RUN}/${HIST_VERSION}/${HIST_VAR}/*1979*.nc))
REF_FILES_ORIG := $(sort $(wildcard /g/data/${NCI_LOC}/CMIP5/combined/*/${MODEL}/${EXPERIMENT}/day/atmos/day/${RUN}/${REF_VERSION}/${REF_VAR}/*.nc))
TARGET_FILES_ORIG := $(wildcard /g/data/xv83/agcd-csiro/${TARGET_VAR}/daily/*_AGCD-CSIRO_r005_*_daily_space-chunked.zarr)

OUTPUT_HIST_DIR=/g/data/wp00/users/dbi599/QQ-CMIP5/${MODEL}/historical/${RUN}/day/${HIST_VAR}/${HIST_VERSION}
OUTPUT_REF_DIR=/g/data/wp00/users/dbi599/QQ-CMIP5/${MODEL}/${EXPERIMENT}/${RUN}/day/${REF_VAR}/${REF_VERSION}
OUTPUT_TARGET_DIR=/g/data/wp00/data/${OBS_DATASET}
ifeq (${SSR}, --ssr)
HIST_DATA=${OUTPUT_HIST_DIR}/${HIST_VAR}-ssr_day_${MODEL}_historical_${RUN}_${HIST_START}0101-${HIST_END}1231.nc
HIST_UNITS=${OUTPUT_UNITS}
REF_DATA=${OUTPUT_REF_DIR}/${REF_VAR}-ssr_day_${MODEL}_${EXPERIMENT}_${RUN}_${REF_START}0101-${REF_END}1231.nc
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

AF_FILE=${REF_FNAME_VAR}-${METHOD}-${SCALING}-monthly-adjustment-factors_${MODEL}_${EXPERIMENT}_${RUN}_${REF_START}0101-${REF_END}1231_wrt_${HIST_START}0101-${HIST_END}1231.nc
AF_PATH=${OUTPUT_REF_DIR}/${AF_FILE}

QQ_BASE=${REF_FNAME_VAR}_day_${MODEL}_${EXPERIMENT}_${RUN}_AUS-r005_${REF_START}0101-${REF_END}1231_${METHOD}-${SCALING}-monthly_${OBS_DATASET}-${TARGET_START}0101-${TARGET_END}1231_historical-${HIST_START}0101-${HIST_END}1231
QQ_PATH=${OUTPUT_REF_DIR}/${QQ_BASE}.nc

VALIDATION_NOTEBOOK=${OUTPUT_REF_DIR}/${QQ_BASE}.ipynb

QQ_MEAN_MATCH_PATH=${OUTPUT_REF_DIR}/${QQ_BASE}_${MEAN_MATCH_TIMESCALE}-mean-match.nc





