function approach(val, goal, step) {
	return (val > goal) ? max(val - step, goal) : min(val + step, goal);
}