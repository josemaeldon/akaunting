<?php

namespace ConsoleTVs\Charts\Facades;

use Illuminate\Support\Facades\Facade;

class Charts extends Facade
{
    protected static function getFacadeAccessor()
    {
        return 'charts';
    }
}
