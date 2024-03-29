# Workflow for QDM, EDCDFm or EQCDFm
#
#   CONFIG file needs the following variables defined:
#   - Methods details: SCALING, GROUPING, NQUANTILES, INTERP, SSR, OUTPUT_GRID
#   - Paths for files that will be created: AF_PATH, QQ_PATH, VALIDATION_NOTEBOOK, FINAL_QQ_PATH 
#   - Directories that need to be created for those files: OUTPUT_AF_DIR, OUTPUT_QQ_DIR, OUTPUT_VALIDATION_DIR
#   - Variables: HIST_VAR, REF_VAR, TARGET_VAR
#   - Input data: HIST_DATA, REF_DATA, TARGET_DATA
#   - Time bounds: HIST_START, HIST_END, REF_START, REF_END, TARGET_START, TARGET_END, REF_TIME
#   - Units: HIST_UNITS, REF_UNITS, TARGET_UNITS, OUTPUT_UNITS
#

.PHONY: help clean-up

include ${CONFIG}

#PYTHON=/g/data/wp00/users/dbi599/miniconda3/envs/cih/bin/python
PYTHON=/g/data/xv83/dbi599/miniconda3/envs/qqscale/bin/python
PAPERMILL=/g/data/xv83/dbi599/miniconda3/envs/qqscale/bin/papermill
CODE_DIR=~/qqscale
TEMPLATE_NOTEBOOK=~/qq-workflows/validation.ipynb


check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

$(call check_defined, PYTHON)
$(call check_defined, PAPERMILL)
$(call check_defined, CODE_DIR)
$(call check_defined, TEMPLATE_NOTEBOOK)

$(call check_defined, SCALING)
$(call check_defined, NQUANTILES)
$(call check_defined, INTERP)
$(call check_defined, OUTPUT_GRID)
#Optional: GROUPING, SSR

$(call check_defined, AF_PATH)
$(call check_defined, QQ_PATH)
$(call check_defined, VALIDATION_NOTEBOOK)
$(call check_defined, FINAL_QQ_PATH)

$(call check_defined, OUTPUT_AF_DIR)
$(call check_defined, OUTPUT_QQ_DIR)
$(call check_defined, OUTPUT_VALIDATION_DIR)

$(call check_defined, HIST_VAR)
$(call check_defined, REF_VAR)
$(call check_defined, TARGET_VAR)

$(call check_defined, HIST_DATA)
$(call check_defined, REF_DATA)
$(call check_defined, TARGET_DATA)

$(call check_defined, HIST_START)
$(call check_defined, HIST_END)
$(call check_defined, REF_START)
$(call check_defined, REF_END)
$(call check_defined, TARGET_START)
$(call check_defined, TARGET_END)
#Optional: REF_TIME, OUTPUT_TSLICE

$(call check_defined, HIST_UNITS)
$(call check_defined, REF_UNITS)
$(call check_defined, TARGET_UNITS)
$(call check_defined, OUTPUT_UNITS)


## train: Calculate the QQ-scale adjustment factors
train : ${AF_PATH}
${AF_PATH} :
	mkdir -p ${OUTPUT_AF_DIR}
	${PYTHON} ${CODE_DIR}/train.py ${HIST_VAR} ${REF_VAR} $@ --hist_files ${HIST_DATA} --ref_files ${REF_DATA} --hist_time_bounds ${HIST_START}-01-01 ${HIST_END}-12-31 --ref_time_bounds ${REF_START}-01-01 ${REF_END}-12-31 --scaling ${SCALING} --nquantiles ${NQUANTILES} ${GROUPING} --input_hist_units ${HIST_UNITS} --input_ref_units ${REF_UNITS} --output_units ${OUTPUT_UNITS} --verbose ${SSR} ${VALID_MIN} ${VALID_MAX} ${COMPRESSION}

## adjust: Apply adjustment factors to the target data
adjust : ${QQ_PATH}
${QQ_PATH} : ${AF_PATH}
	mkdir -p ${OUTPUT_QQ_DIR}
	${PYTHON} ${CODE_DIR}/adjust.py ${TARGET_DATA} ${TARGET_VAR} $< $@ --adjustment_tbounds ${TARGET_START}-01-01 ${TARGET_END}-12-31 --input_units ${TARGET_UNITS} --output_units ${OUTPUT_UNITS} --spatial_grid ${OUTPUT_GRID} --interp ${INTERP} --verbose ${SSR} ${OUTPUT_TSLICE} ${OUTFILE_ATTRIBUTES} ${REF_TIME} ${MAX_AF} ${VALID_MIN} ${VALID_MAX} ${COMPRESSION}

## clipmax: Clip the quantile scaled data to a given upper bound
clipmax : ${QQCLIPPED_PATH}
${QQCLIPPED_PATH} : ${QQ_PATH}
	${PYTHON} ${CODE_DIR}/clipmax.py $< ${TARGET_VAR} $@ --maxfiles ${MAX_DATA} --maxvar ${MAX_VAR} ${COMPRESSION}

## validation : Create validation notebook
validation : ${VALIDATION_NOTEBOOK}
${VALIDATION_NOTEBOOK} : ${TEMPLATE_NOTEBOOK} ${AF_PATH} ${QQ_PATH} ${QQCLIPPED_PATH}
	mkdir -p ${OUTPUT_VALIDATION_DIR}
	${PAPERMILL} -p adjustment_file $(word 2,$^) -p qq_file $(word 3,$^) -r hist_files "${HIST_DATA}" -r ref_files "${REF_DATA}" -r target_files "${TARGET_DATA}" -r hist_time_bounds "${HIST_START}-01-01 ${HIST_END}-12-31" -r ref_time_bounds "${REF_START}-01-01 ${REF_END}-12-31" -r target_time_bounds "${TARGET_START}-01-01 ${TARGET_END}-12-31" -p hist_units ${HIST_UNITS} -p ref_units ${REF_UNITS} -p target_units ${TARGET_UNITS} -p output_units ${OUTPUT_UNITS} -p hist_var ${HIST_VAR} -p ref_var ${REF_VAR} -p target_var ${TARGET_VAR} -p scaling ${SCALING} -p nquantiles ${NQUANTILES} ${CLIP_VALIDATION} $< $@

## split-by-year: Create (and compress) an individual file for each year
split-by-year : ${FINAL_QQ_PATH}
	bash ${SPLIT_SCRIPT} $<

## clean up: remove unneeded files once the split into years process is done
clean-up : 
	rm ${QQ_PATH} ${QQCLIPPED_PATH}

## help : show this message
help :
	@echo 'make [target] [-Bn] CONFIG=config_file.mk'
	@echo ''
	@echo 'valid targets:'
	@grep -h -E '^##' ${MAKEFILE_LIST} | sed -e 's/## //g' | column -t -s ':'

