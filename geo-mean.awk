#!/usr/bin/awk -f

function handle_D_exp(x){
  sub("D", "e", x)
  return x+0
}

BEGIN{
  lmax=-9999999999
  lmin= 9999999999
  FILE_COUNT=0
  GM1=398600.4415e9
  R1=6378136.30
}
{
  if (FNR==1){ 
    FILE_COUNT+=1
    FMT1=$0 
  } else if (FNR==2){
    if (NF==3) {
      NAME=$1
      GM=$2
      R=$3
    } else if (FNF==4) {
      NAME=sprintf("%s %s",$1,$2)
      GM=$3
      R=$4
    } else {
      printf("ERROR: cannot handle GEO header line %s:\n%s\n",NR,$0)
      exit_invoked=1
      exit 1
    }
  } else if (FNR==3){
    FMT2=$0
  } else {
    #need to parse tag, degree and order
    if (length($1)==12){
      # printf("12:")
      tag=substr($1,1 , 6)
        d=substr($1,7 , 3)+0
        o=substr($1,10, 3)+0
      SHCi=$2
      SHSi=$3
      SHCiv=$4
      SHSiv=$5
    } else if (length($1)==6) {
      # printf("6:")
      tag=$1
      if (length($2)==1 || length($2)==2) {
        # printf("1,2:")
        d=$2
        o=$3
        SHCi =$4
        SHSi =$5
        SHCiv=$6
        SHSiv=$7
      } if (length($2)==4 || length($2)==5) {
        if (length($2)==4) {  
          # printf("4:")
          d=substr($1,1,1)+0
          o=substr($1,2,3)+0
        } else {
          # printf("5:")
          d=substr($1,1,2)+0
          o=substr($1,3,3)+0
        }
        SHCi =$3
        SHSi =$4
        SHCiv=$5
        SHSiv=$6
      }
    } else if (length($1)==9) {
      # printf("9:")
      tag=substr($1,1,6)
      d  =substr($1,7,3)+0
      o=$2
      SHCi =$3
      SHSi =$4
      SHCiv=$5
      SHSiv=$6
    } else {
      printf("ERROR: cannot handle GEO data at line %d:\n%s\n",FNR,$0)
      exit_invoked=1
      exit 1
    }
    #make values numeric
    SHCi =handle_D_exp(SHCi)
    SHSi =handle_D_exp(SHSi)
    SHCiv=handle_D_exp(SHCiv)
    SHSiv=handle_D_exp(SHSiv)
    if (tag=="RECOEF"){
      if (lmax<d) {
        lmax=d
      }
      if (lmin>d) {
        lmin=d
      }
      # print "lmax=",lmax,"lmin=",lmin,"d=",d,"o=",o
      scale=(R/R1)^d*(GM1/GM)
       SHC[d,o]+=scale*SHCi
       SHS[d,o]+=scale*SHSi
      SHCv[d,o]+=SHCiv*SHCiv
      SHSv[d,o]+=SHSiv*SHSiv
    } else {
      printf("ERROR: cannot handle GEO files with %d columns (fault at line %d)\n",NF,FNR)      
      exit_invoked=1
      exit 1
    } 
  }
  # print tag,d,o,SHC[d,o],SHS[d,o],SHCv[d,o],SHSv[d,o]
} END {
  if (! exit_invoked  ) {
    print FMT1
    printf("%20s%20.10e%20.10e\n","sum",GM1,R1)
    print FMT2
    for (di = lmin; di <= lmax; di++) {
      for (oi = 0; oi <= di; oi++) {
        printf("%6s%3d%3d %20.13e %20.13e %10.4e %10.4e %2.0f.\n",tag,di,oi,SHC[di,oi]/FILE_COUNT,SHS[di,oi]/FILE_COUNT,sqrt(SHCv[di,oi])/FILE_COUNT,sqrt(SHSv[di,oi])/FILE_COUNT,-1)
      }
    }
  }  
}