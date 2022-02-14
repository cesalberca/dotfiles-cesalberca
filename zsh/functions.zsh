gif_opt () {
	mkdir min;
	for f in *.gif; do
		gifsicle --resize-fit-width $1 -i "$f" > "min/${f%.gif}.gif"
	done;
}