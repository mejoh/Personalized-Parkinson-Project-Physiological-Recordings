#!/usr/bin/perl
###################################################################
#                 RL 2004 IBT Zurich (Switzerland)                #
#                     http://www.mr.ethz.ch/                      #
#                     Rec (PMS format) to Analyze                 #
###################################################################

#June 2005: additional feature added Marcel Warntjes
#June 2005: convert no longer needed and others bugfixes by Adam Espe Hansen
#                 adesha01@glostruphosp.kbhamt.dk  Glostrup (Denmark)
#June 2005: splitting of Multi echo/hp/type scans
#           correct reordering of the images

#default 1 File pro Scan
$fsl=1;

#show some addtional infos
$display=0;

#allow to extract 1. HP, Echo ImageType out of an multidimanional scan
$scan_split=0;

#debugging info
$verbose=0;

#use convert (only under Linux)
$no_convert=0;

#Path only needed it a current (>5.4) version can not be called by the command convert!
#add an / at the end!
#an old version of convert can be recongnized if the output of rec2analyze has just 2 gray values!
$path_convert="";
#$path_convert="/usr/X11R6/bin/";

$fsl_and_spm_flop_true=0;
while ($ARGV[0] =~ /^-/) {
  $_ = shift @ARGV;
  if (/^-h(elp)?$/) {
    &usage;
  } elsif (/^-spm$/) {
    $fsl=0;
  } elsif (/^-fsl$/) {
    $fsl=1;
  } elsif (/^-fsl_flop$/) {
    $fsl_and_spm_flop='-flop';
    $fsl_and_spm_flop_true=1;
  } elsif (/^-d(isplay)?$/) {
    $display=1;
  } elsif (/^-s(plit)?$/) {
    $scan_split=1;
  } else {
    print "$term_red Unbekannte Option: $_$term_def\n";
    &usage;
  }
}

$file=$ARGV[0];
print "\n";
if ("$file" eq "") {
  print "No file given.\n";
  &usage;
};

# expand *.rec on Windows (standard on Unix)
if ($^O eq "MSWin32"){
  use File::DosGlob;
  @ARGV = map {
    my @g = File::DosGlob::glob($_) if /[*?]/;
    @g ? @g : $_;
  } @ARGV;
}


foreach $file (@ARGV) {
  $image_size=0;
  $par_version=3;
  if (! ( -f "$file")) {
    print "$file does not exist\n";
    &usage;
  } else {
    print "\nFilename: $file\n";
    $base_filename=$file;
    $base_filename=~s/\.[Rr][Ee][Cc]//;
    $par_filename="";
    if ( -f $base_filename."\.par"){
      $par_filename=$base_filename."\.par";
    } elsif ( -f $base_filename."\.PAR"){
      $par_filename=$base_filename."\.PAR";
    } elsif ( -f $base_filename."\.Par"){
      $par_filename=$base_filename."\.Par";
    }
    if (! (-f $par_filename)){
      print "Suitable par-File does not exist!\n";
      &usage;
    }
    #get a few values from the par-file;
    open(FH,"$par_filename");
    my @lines = <FH>;
    close(FH);
    
  LINE1: while ($line=shift(@lines)){
      if ($line=~/^\.    Examination date\/time/){
	($_,$bild_date)=split(/:   /,$line);
	($bild_date,$bild_time)=split(/ \/  /,$bild_date);
      }
      if ($line=~/^\.    Protocol name/){
	($_,$bild_scannum)=split(/:   /,$line);
      }
      if ($line=~/^\.    Image pixel size /){
	($_,$bild_pixel_size)=split(/:   /,$line);
        $bild_pixel_size=1*$bild_pixel_size;
      }
      if ($line=~/^\.    Recon resolution/){
	($_,$bild_resolution)=split(/:   /,$line);
	($_,$image_size)=split(/\s+/,$bild_resolution);
      }
      if ($line=~/^\.    Slice thickness/){
	($_,$bild_slicethickness)=split(/:   /,$line);
      }
      if ($line=~/^\.    Slice gap/){
	($_,$bild_slicegap)=split(/:   /,$line);
      } 
      if ($line=~/^\.    FOV/){
	($_,$bild_FOV)=split(/:  /,$line);
	($bild_FOV_x,$bild_FOV_y,$bild_FOV_z)=split(/\s+/,$bild_FOV);
	($bild_FOV_x,$bild_FOV_y,$bild_FOV_z)=sort {$a <=> $b} ($bild_FOV_x,$bild_FOV_y,$bild_FOV_z);
	$bild_FOV=$bild_FOV_z;
      }
      last LINE1 if ($line=~/^\#sl ec/) || ($line=~/^\# sl ec/) || ($line=~/^\#  sl ec/);
    }
    if ($image_size==0){
      $par_version=4;
    }	
    $anzahl_bilder=0;		#Zahlt Bilder-1
    $max_bild_slice=-1;
    $max_bild_echo=-1;
    $max_bild_dyn=-1;
    $max_bild_heartphase=-1;
    $max_bild_type=-1;
    $min_bild_slice=30000;
    $min_bild_echo=30000;
    $min_bild_dyn=30000;
    $min_bild_heartphase=30000;
    $min_bild_type=30000;

  LINE2: while ($line=shift(@lines)){
      last LINE2 if ($line=~/^\# ===/);
      $line=~s/^\s*//;
      @line_part=split(/\s+/,$line);
      if ($line_part[2]!=""){
	if ($par_version==4){
	  $bild_scale[$anzahl_bilder]=$line_part[12];
	  $bild_intercept[$anzahl_bilder]=$line_part[11];
	  $image_size=$line_part[9];
	  $bild_pixel_size=$line_part[7];
	  $bild_slicegap=$line_part[23];
	  $bild_slicethickness=$line_part[22];
	} else {
	  $bild_scale[$anzahl_bilder]=$line_part[8];
	  $bild_intercept[$anzahl_bilder]=$line_part[7];
	}
	$bild_slice[$anzahl_bilder]=$line_part[0];
	$bild_echo[$anzahl_bilder]=$line_part[1];
	$bild_dyn[$anzahl_bilder]=$line_part[2];
	$bild_heartphase[$anzahl_bilder]=$line_part[3];
	$bild_imagetype[$anzahl_bilder]=$line_part[4];
	$bild_image_nr[$bild_dyn[$anzahl_bilder]][$bild_slice[$anzahl_bilder]][$bild_echo[$anzahl_bilder]][$bild_heartphase[$anzahl_bilder]][$bild_imagetype[$anzahl_bilder]]=$anzahl_bilder;
	if ($verbose){
	  print $bild_dyn[$anzahl_bilder]." ".$bild_slice[$anzahl_bilder]." ".$bild_echo[$anzahl_bilder]." ".$bild_heartphase[$anzahl_bilder]." ".$bild_imagetype[$anzahl_bilder].":".$bild_image_nr[$bild_dyn[$anzahl_bilder]][$bild_slice[$anzahl_bilder]][$bild_echo[$anzahl_bilder]][$bild_heartphase[$anzahl_bilder]][$bild_imagetype[$anzahl_bilder]]."SS".$bild_scale[$anzahl_bilder].":".$bild_intercept[$anzahl_bilder]."\n";
	}
	($max_bild_slice>=$line_part[0]) || ($max_bild_slice=$line_part[0]);
	($max_bild_echo>=$line_part[1]) || ($max_bild_echo=$line_part[1]);
	($max_bild_dyn>=$line_part[2]) || ($max_bild_dyn=$line_part[2]);
	($max_bild_heartphase>=$line_part[3]) || ($max_bild_heartphase=$line_part[3]);
	($max_bild_type>=$line_part[4]) || ($max_bild_type=$line_part[4]);
	($min_bild_slice<=$line_part[0]) || ($min_bild_slice=$line_part[0]);
	($min_bild_echo<=$line_part[1]) || ($min_bild_echo=$line_part[1]);
	($min_bild_dyn<=$line_part[2]) || ($min_bild_dyn=$line_part[2]);
	($min_bild_heartphase<=$line_part[3]) || ($min_bild_heartphase=$line_part[3]);
	($min_bild_type<=$line_part[4]) || ($min_bild_type=$line_part[4]);
	$anzahl_bilder++;
      }
    }
    if ($image_size==0) {
      die "Not a version 3 or 4 Par-File...\n";
    }  else {
      print "Version $par_version Par-File could be readed.\n";
    }

    $temp_type="";
    for ($loop_type=$min_bild_type;$loop_type<=$max_bild_type;$loop_type++){
      if (defined $bild_image_nr[$min_bild_dyn][$min_bild_slice][$min_bild_echo][$min_bild_heartphase][$loop_type]){
	$temp_type="$temp_type$loop_type  ";
      }
    }
    
    if ($display) {           #display some parameters if requested with -d.
      print "PARRECversion  = $par_version\n";
      print "date time      = $bild_date";
      print "scan name      = $bild_scannum";
      print "pixel size     = $bild_pixel_size\n";
      print "image size     = $image_size\n";
      print "dynamic scan   = $bild_dyn[0]\n";
      print "image scale    = $bild_scale[0]\n";
      print "image intercept= $bild_intercept[0]\n";
      print "sl thickness   = $bild_slicethickness\n";
      print "slice gap      = $bild_slicegap\n";
      print "Nr of Dynamics = $max_bild_dyn\n";
      print "Nr of Slices   = $min_bild_slice - $max_bild_slice\n";
      print "Nr of Echos    = $min_bild_echo - $max_bild_echo\n";
      print "Nr of HP       = $min_bild_heartphase - $max_bild_heartphase\n";
      print "Nr of Types    = $temp_type\n";
    }

    if ($scan_split==0){
      if ($max_bild_echo != $min_bild_echo){
	die ("\n\nError: More than one echo: $min_bild_echo - $max_bild_echo\nUse option -split!\n");
      }
      if ($max_bild_heartphase != $min_bild_heartphase){
	die ("\n\nError: More than one heartphase: $min_bild_heartphase - $max_bild_heartphase\nUse option -split!\n");
      }
      if ($max_bild_type != $min_bild_type){
	die ("\n\nError: More than one image type: $temp_type\nUse option -split!\n");
      }
      if (($max_bild_slice-$min_bild_slice+1)*($max_bild_dyn-$min_bild_dyn+1)!=$anzahl_bilder){
	die ("\n\nError: Wrong number of images!\nSlices: ".($max_bild_slice-$min_bild_slice+1)."\nDynamics: ".($max_bild_dyn-$min_bild_dyn+1)."\nImages: $anzahl_bilder\nUse option -split!\n\n");
      }
    }
    if (($max_bild_slice-$min_bild_slice+1)*($max_bild_dyn-$min_bild_dyn+1)!=$anzahl_bilder){
      print ("\n\nError: Wrong number of images!\nSlices: ".($max_bild_slice-$min_bild_slice+1)."\nDynamics: ".($max_bild_dyn-$min_bild_dyn+1)."\nImages: $anzahl_bilder\n\n");
      $max_bild_dyn_calc=$min_bild_dyn-1+int($anzahl_bilder/($max_bild_slice-$min_bild_slice+1));
      if ($max_bild_dyn_calc<$max_bild_dyn){
	$max_bild_dyn=$max_bild_dyn_calc;
	print "Number of dynamics will be reduced.\n";
      }
      $anzahl_bilder=($max_bild_slice-$min_bild_slice+1)*($max_bild_dyn-$min_bild_dyn+1);
      print "new values:\nSlices: ".($max_bild_slice-$min_bild_slice+1)."\nDynamics: ".($max_bild_dyn-$min_bild_dyn+1)."\nImages: $anzahl_bilder\n";
    }


    $bildsizebyte=$image_size*$image_size*$bild_pixel_size/8;
    $pixels=$image_size;
    $image_size="${image_size}x${image_size}";

    print "\nStarting reordering (tot: ".($anzahl_bilder)." images): ";
    for ($loop_echo=$min_bild_echo;$loop_echo<=$max_bild_echo;$loop_echo++){
      for ($loop_hp=$min_bild_heartphase;$loop_hp<=$max_bild_heartphase;$loop_hp++){
      TYPE: for ($loop_type=$min_bild_type;$loop_type<=$max_bild_type;$loop_type++){
	    if (!defined $bild_image_nr[$min_bild_dyn][$min_bild_slice][$loop_echo][$loop_hp][$loop_type]){
	      next;
	    }
	    #-----loop over dynamics
	    for ($loop_dyn=$min_bild_dyn;$loop_dyn<=$max_bild_dyn;$loop_dyn++){
	      if (!$fsl || $loop_dyn==$min_bild_dyn){
		$stellen=length($max_bild_dyn);
		$addition_filename="";
		if ($max_bild_echo != $min_bild_echo){
		  $addition_filename=$addition_filename."_ec$loop_echo";
		}
		if ($max_bild_heartphase != $min_bild_heartphase){
		  $addition_filename=$addition_filename."_hp$loop_hp";
		}
		if ($max_bild_type != $min_bild_type){
		  $addition_filename=$addition_filename."_typ$loop_type";
		}
		if ($fsl) {
		  $target="$base_filename$addition_filename"; 
		} else {
		  $target="$base_filename$addition_filename"."x".substr("000000000".($loop_dyn),-$stellen,$stellen);
		}		
		&write_hdr_file($loop_dyn,$min_bild_slice, $loop_echo, $loop_hp, $loop_type);
		if (($^O eq "MSWin32") || ($no_convert==1)) {
		  open(TARGET,">$target\.img");
		} else {
		  open(TARGET,"| ${path_convert}convert -size $image_size -depth $bild_pixel_size -flip $fsl_and_spm_flop gray:- gray:$target\.img") || die "can't write img-File";
		}
		print "\n$target\.img :\n";
	      } else {
		close(TARGET);
		if (($^O eq "MSWin32") || ($no_convert==1)) {
		  open(TARGET,">>$target\.img") || die "can't append to img-File $target\.img";
		} else {
		  open(TARGET,"| ${path_convert}convert -size $image_size -depth $bild_pixel_size -flip $fsl_and_spm_flop gray:- gray:- >>$target\.img") || die "can't append to img-File $target\.img";
		}
	      }
	      binmode(TARGET);
	      #-----loop over slices	
	      for ($loop_slice=$min_bild_slice;$loop_slice<=$max_bild_slice;$loop_slice++){
		$j=(($loop_dyn-1)*$max_bild_slice)+$loop_slice;
		if (($j%20==0)&&($display!=1)){print "\n"};
		print "$j ";
		sysseek(MAIN,$bild_image_nr[$loop_dyn][$loop_slice][$loop_echo][$loop_hp][$loop_type]*$bildsizebyte,0);
		if($verbose){
		  print "dyn: $loop_dyn; slices: $loop_slice; echo: $loop_echo; hp: $loop_hp; type: $loop_type; offset: ".$bild_image_nr[$loop_dyn][$loop_slice][$loop_echo][$loop_hp][$loop_type]."\n";
		}
		sysread(MAIN,$bild,$bildsizebyte,0) || die ("no data");
		if (($^O eq "MSWin32") || ($no_convert==1)) {
		  for ($m = 1; $m <= $pixels; $m++){
		    for ($n = 1; $n <= $pixels; $n++){
		      vec($bild_neu,(($pixels-$m)*$pixels+(1-$fsl_and_spm_flop_true)*($n-1)+$fsl_and_spm_flop_true*($pixels-$n)),$bild_pixel_size)=vec($bild,(($m-1)*$pixels+$n-1),$bild_pixel_size);
		    }
		  }
		  $bild=$bild_neu;
		}
		syswrite(TARGET,$bild);
	      }
	    }
	    close(MAIN);
	    close(TARGET);
	  }
      }
    }
    print "\n...all images reordered ($anzahl_bilder Images)\n";
  }
}	

sub write_hdr_file {
  $current_image_nr=$bild_image_nr[$_[0]][$_[1]][$_[2]][$_[3]][$_[4]];
  ($verbose)&&print "current_image_nr: $current_image_nr, $_[0], $_[1], $_[2], $_[3], $_[4]\n";
  $current_dyn=$_[0];
  $current_echo=$_[2];
  $current_heartphase=$_[3];
  $current_type=$_[4];
  $bild_res=$bild_FOV/$image_size;
  #datafile open
  open(MAIN,"$file") || die "can't open rec-file";
  binmode(MAIN);

  
  #save hdr-File
  open(FH,">$target.hdr") || die;
  binmode(FH);
  $leer_string=pack("C255",0);
  syswrite FH,pack("l",348),4,0; #size_of_hdr
  syswrite FH,pack("C10",(100,115,114,32,32,32,32,32,32,0)),10,0;
  syswrite FH,"$base_filename$leer_string",17,0;
  syswrite FH,$leer_string,7,0;
  syswrite FH,"r",1,0;
  syswrite FH,$leer_string,1,0; 
  if ($fsl) {
    $dyn=$max_bild_dyn;
  } else {
    $dyn=1;
  }
  syswrite FH,pack("S8",(4,$image_size,$image_size,$max_bild_slice,$dyn,0,0,0)),16,0; #dim, recon_dim_x,-_y,slices,time,0,0,0
  syswrite FH,"mm$leer_string",14,0;
  if ($bild_pixel_size eq 16) {
    syswrite FH,pack("S",4),2,0; #sign short
    syswrite FH,pack("S",16),2,0; #16
  } else {
    syswrite FH,pack("S",2),2,0; #sign byte
    syswrite FH,pack("S",8),2,0; #8
  }
  syswrite FH,$leer_string,2,0;
  if ($fsl_and_spm_flop ne '-flop') {
    syswrite FH,pack("f9",(0.0,$bild_res,$bild_res,$bild_slicethickness+$bild_slicegap,0,0,0,0,0)),36,0; #FOV/recon_res.
  } else {
    syswrite FH,pack("f9",(0.0,-$bild_res,$bild_res,$bild_slicethickness+$bild_slicegap,0,0,0,0,0)),36,0; #FOV/recon_res.
  }
  syswrite FH,pack("f2",($bild_scale[$current_image_nr],$bild_intercept[$current_image_nr])),8,0; #rescale slope and intercept
  syswrite FH,$leer_string,20,0;
  syswrite FH,pack("S4",(32767,00,0,0)),8,0; #glmax,glmin
  syswrite FH,$leer_string,80,0; #description
  syswrite FH,"none$leer_string",23,0;
  syswrite FH,pack("C",0),1,0;
  syswrite FH,"$leer_string",1,0;
  syswrite FH,pack("S5",($image_size/2,$image_size/2,$max_bild_slice/2,0,0)),10,0;
  #  syswrite FH,pack("S5",(0,0,0,0,0)),10,0;
  syswrite FH,"IBT$leer_string",9,0; #generated
  syswrite FH,pack("C",0),1,0;
  syswrite FH,"$bild_scannum$leer_string",9,0; #scannum
  syswrite FH,pack("C",0),1,0;
  syswrite FH,"$leer_string",9,0; #pat_id
  syswrite FH,pack("C",0),1,0;
  syswrite FH,"$bild_date$leer_string",9,0; #exp_date
  syswrite FH,pack("C",0),1,0;
  syswrite FH,"$bild_time$leer_string",8,0; #exp_time
  syswrite FH,pack("C2",0),2,0;
  syswrite FH,"$leer_string",35,0; #leer
  close(FH);
  #end save HDR-File
}

sub usage {
  print "\n\nUsage:  $0 [-fsl -spm] [-fsl_flop] files.rec
-d[isplay] : display header parameters needed in analyze format
-spm       : create spm99 Files (1 Analyse file per dynamic)
-fsl       : create fsl Files (1 Analyse file) (default)
-fsl_flop  : additional right-left flop (mirroring)
             flop images and add a - in x-Voxelsize (not valid for spm)
-s[plit]   : force to write a analyze-File even if more than one HP,
             Echo or ImageType is in the file.\n\n";
  exit;
}
