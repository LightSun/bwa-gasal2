
CC=			gcc
VPATH=src:obj:lib
OBJ_DIR=./obj/
LIB_DIR=./lib/
CUDA_LIB_DIR=/usr/local/cuda-8.0/lib64
GASAL_LIB_DIR = /home/nahmed/bulk/gasal2/lib
GASAL_INCLUDE_DIR = /home/nahmed/bulk/gasal2/include
#SHD_DIR=./src/shd_filter/
#CC=			clang --analyze
CFLAGS=		-g -Wall -Wno-unused-function -O2 -msse4.2
NVCCFLAGS = -g -lineinfo --gpu-architecture=compute_35 --gpu-code=sm_35 -O3 -Xcompiler -Wall -Xptxas -Werror --default-stream per-thread 
WRAP_MALLOC=-DUSE_MALLOC_WRAPPERS
AR=			ar
DFLAGS=		-DHAVE_PTHREAD $(WRAP_MALLOC)

LOBJS=		utils.o kthread.o kstring.o ksw.o bwt.o bntseq.o bwa.o bwamem.o bwamem_pair.o bwamem_extra.o malloc_wrap.o \
			QSufSort.o bwt_gen.o rope.o rle.o is.o bwtindex.o 
LOBJS_PATH=$(addprefix $(OBJ_DIR),$(LOBJS))
SHD_OBJS=mask.o print.o bit_convert.o popcount.o vector_filter.o
SHD_OBJS_PATH=$(addprefix $(OBJ_DIR),$(SHD_OBJS))
#GASAL_OBJS=gasal.o
#GASAL_OBJS_PATH=$(addprefix $(OBJ_DIR),$(GASAL_OBJS))
#SHD_SRC_PATH=$(addprefix $(SHD_DIR),$(SHD_OBJS))
AOBJS=		bwashm.o bwase.o bwaseqio.o bwtgap.o bwtaln.o bamlite.o \
			bwape.o kopen.o pemerge.o maxk.o \
			bwtsw2_core.o bwtsw2_main.o bwtsw2_aux.o bwt_lite.o \
			bwtsw2_chain.o fastmap.o bwtsw2_pair.o
AOBJS_PATH=$(addprefix $(OBJ_DIR),$(AOBJS))
PROG=		gase
INCLUDES= -I$(GASAL_INCLUDE_DIR) 
LIBS=		-lm -lz -lpthread -lcudart
SUBDIRS=	.

ifeq ($(shell uname -s),Linux)
	LIBS += -lrt
endif

.SUFFIXES:.c .o .cc .cpp .cu

.c.o:
		$(CC) -c $(CFLAGS) $(DFLAGS) $(INCLUDES) $< -o $(OBJ_DIR)$@

.cpp.o:
		g++ -c $(CFLAGS) $(INCLUDES) $< -o $(OBJ_DIR)$(notdir $@)
		
#.cu.o:
#		 nvcc -c $(NVCCFLAGS) $(INCLUDES) $< -o $(OBJ_DIR)$(notdir $@)


all: makedir $(PROG) 

makedir:
	@mkdir -p $(OBJ_DIR)
	@mkdir -p $(LIB_DIR)
	@echo "If you donot see anything below this line then there is nothing to \"make\""

gase:libbwa.a libshd_filter.a  $(AOBJS) main.o
		$(CC) $(CFLAGS) $(DFLAGS) $(AOBJS_PATH) $(OBJ_DIR)main.o -o $@ -L$(LIB_DIR) -L$(CUDA_LIB_DIR)  -L$(GASAL_LIB_DIR) -lbwa -lshd_filter -lgasal $(LIBS)


libbwa.a:$(LOBJS)
		$(AR) -csru $(LIB_DIR)$@ $(LOBJS_PATH)

libshd_filter.a: $(SHD_OBJS)
		#make -C ./src/shd_filter libshd_filter.a
		ar -csru $(LIB_DIR)$@ $(SHD_OBJS_PATH)
		
#libgasal.a: $(GASAL_OBJS)
		#make -C ./src/shd_filter libshd_filter.a
		#ar -csru $(LIB_DIR)$@ $(GASAL_OBJS_PATH) 		

clean:
		rm -f -r gmon.out $(OBJ_DIR) a.out $(PROG) *~ $(LIB_DIR)
		#make -C ./src/shd_filter/ clean

#depend:
#	( LC_ALL=C ; export LC_ALL; cd src; makedepend -Y -- $(CFLAGS) $(DFLAGS) -- -f ../Makefile -p $(OBJ_DIR)  *.c *.cpp )
depend:
	( LC_ALL=C ; export LC_ALL; cd src; makedepend -Y -- $(CFLAGS) $(DFLAGS) -- -f ../Makefile  *.c *.cpp )
	

# DO NOT DELETE THIS LINE -- make depend depends on it.

QSufSort.o: QSufSort.h
bamlite.o: bamlite.h malloc_wrap.h
bntseq.o: bntseq.h utils.h kseq.h malloc_wrap.h khash.h
bwa.o: bntseq.h bwa.h bwt.h ksw.h utils.h kstring.h malloc_wrap.h kvec.h
bwa.o: kseq.h
bwamem.o: kstring.h malloc_wrap.h bwamem.h bwt.h bntseq.h bwa.h ksw.h kvec.h
bwamem.o: ksort.h utils.h vector_filter.h kbtree.h
bwamem_extra.o: bwa.h bntseq.h bwt.h bwamem.h kstring.h malloc_wrap.h
bwamem_pair.o: kstring.h malloc_wrap.h bwamem.h bwt.h bntseq.h bwa.h kvec.h
bwamem_pair.o: utils.h ksw.h
bwape.o: bwtaln.h bwt.h kvec.h malloc_wrap.h bntseq.h utils.h bwase.h bwa.h
bwape.o: ksw.h khash.h
bwase.o: bwase.h bntseq.h bwt.h bwtaln.h utils.h kstring.h malloc_wrap.h
bwase.o: bwa.h ksw.h
bwaseqio.o: bwtaln.h bwt.h utils.h bamlite.h malloc_wrap.h kseq.h
bwashm.o: bwa.h bntseq.h bwt.h
bwt.o: utils.h bwt.h kvec.h malloc_wrap.h
bwt_gen.o: QSufSort.h malloc_wrap.h
bwt_lite.o: bwt_lite.h malloc_wrap.h
bwtaln.o: bwtaln.h bwt.h bwtgap.h utils.h bwa.h bntseq.h malloc_wrap.h
bwtgap.o: bwtgap.h bwt.h bwtaln.h malloc_wrap.h
bwtindex.o: bntseq.h bwa.h bwt.h utils.h rle.h rope.h malloc_wrap.h
bwtsw2_aux.o: bntseq.h bwt_lite.h utils.h bwtsw2.h bwt.h kstring.h
bwtsw2_aux.o: malloc_wrap.h bwa.h ksw.h kseq.h ksort.h
bwtsw2_chain.o: bwtsw2.h bntseq.h bwt_lite.h bwt.h malloc_wrap.h ksort.h
bwtsw2_core.o: bwt_lite.h bwtsw2.h bntseq.h bwt.h kvec.h malloc_wrap.h
bwtsw2_core.o: khash.h ksort.h
bwtsw2_main.o: bwt.h bwtsw2.h bntseq.h bwt_lite.h utils.h bwa.h
bwtsw2_pair.o: utils.h bwt.h bntseq.h bwtsw2.h bwt_lite.h kstring.h
bwtsw2_pair.o: malloc_wrap.h ksw.h
example.o: bwamem.h bwt.h bntseq.h bwa.h kseq.h malloc_wrap.h
fastmap.o: bwa.h bntseq.h bwt.h bwamem.h kvec.h malloc_wrap.h utils.h kseq.h
is.o: malloc_wrap.h
kopen.o: malloc_wrap.h
kstring.o: kstring.h malloc_wrap.h
ksw.o: ksw.h malloc_wrap.h
main.o: kstring.h malloc_wrap.h utils.h
malloc_wrap.o: malloc_wrap.h
maxk.o: bwa.h bntseq.h bwt.h bwamem.h kseq.h malloc_wrap.h
pemerge.o: ksw.h kseq.h malloc_wrap.h kstring.h bwa.h bntseq.h bwt.h utils.h
rle.o: rle.h
rope.o: rle.h rope.h
utils.o: utils.h ksort.h malloc_wrap.h kseq.h
bit_convert.o: print.h bit_convert.h
bit_convertMain.o: bit_convert.h
countPassFilter.o: vector_filter.h mask.h
mask.o: mask.h
popcount.o: popcount.h mask.h
popcountMain.o: popcount.h
print.o: print.h
read_modifier.o: read_modifier.h
shiftMain.o: vector_filter.h mask.h
string_cp.o: print.h
test_modifier.o: read_modifier.h vector_filter.h
vector_filter.o: print.h vector_filter.h popcount.h bit_convert.h mask.h
vector_filterMain.o: vector_filter.h mask.h
gasal.o: gasal.h gasal_kernels_inl.h