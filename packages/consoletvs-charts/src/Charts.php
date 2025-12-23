<?php

namespace ConsoleTVs\Charts;

class Charts
{
    public function create($type, $library)
    {
        return new ChartBuilder($type, $library);
    }

    public function multi($type, $library)
    {
        return new MultiChartBuilder($type, $library);
    }
}
