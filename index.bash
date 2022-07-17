#!/bin/bash
# Copyright (c) 2021 Kona Arctic. All rights reserved. ABSOLUTELY NO WARRANTY!
set -o errexit
shopt -s dotglob
shopt -s extglob
shopt -s globstar
shopt -s nullglob
IFS=

for item in "." ** ; do
	if [[ -d $item ]] ; then
		if [[ -f "$item/index.html" ]] ; then
			echo "W $item/index.html already exists, skipping." 1>&2
		else
			echo "
				<HTML>
					<HEAD>
						<TITLE>
							Directory
						</TITLE>
						<META 
							NAME=VIEWPORT
							CONTENT=\"
								WIDTH=DEVICE-WIDTH,
								INITIAL-SCALE=1,
							\"
						>
					</HEAD>
					<BODY>
						<CENTER>
							<H1>
								Directory
							</H1>
							<TABLE>
								<TR>
									<TH>
										Name
									</TH>
									<TH>
										Type
									</TH>
									<TH>
										Size
									</TH>
									<TH>
										Date
									</TH>
								</TR>
								$(
									if [[ $item != "." ]] ; then
										echo "
											<TR>
												<TD>
													<A
														HREF=\"/${item%%?(/)+([^/])?(/)}\"
													>
														Parent
													</A>
												</TD>
												<TD>
													<I>
														par
													</I>
												</TD>
												<TD>
												</TD>
												<TD>
												</TD>
											</TR>
										"
									fi
								)
								$(
									for item in $item/* ; do
										item=${item#./}
										echo "
											<TR>
												<TD>
													<A
														HREF=\"/$item\"
													>
														$(
															if [[ -f $item ]] ; then
																name=${item##*/}
																echo ${name%%.*}
															else
																echo ${item#*/}
															fi
														)
													</A>
												</TD>
												<TD>
													$(
														if [[ -f $item ]] ; then
															exte=${item##*/}
															if [[ ${exte#*.} != $exte ]] ; then
																echo ${exte#*.}
															fi
														else
															echo "
																<I>
																	$(
																		if [[ -d $item ]] ; then
																			echo "dir"
																		else
																			echo "unk"
																		fi
																	)
																</I>"
														fi
													)
												</TD>
												<TD>
													$(
														size=`stat --format=%s $item`
														expo=$[ ( ${#size} - 1 ) / 3 ]
														sigf=$[ ( $size + 1000 ** $expo / 2 ) / 1000 ** $expo ]
														unit=( B K M G T P E Z Y )
														unit=${unit[ $expo ]}
														echo $sigf$unit	# FIXME Decimal
													)
												</TD>
												<TD>
													$(
														date=`stat --format=%y  $item`
														echo ${date%% *}
													)
												</TD>
											</TR>
										"
									done
								)
							</TABLE>
						</CENTER>
					</BODY>
				</HTML>
			" 1> "$item/index.html"
		fi
	fi
done

