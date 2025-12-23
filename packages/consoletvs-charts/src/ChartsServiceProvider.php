<?php

namespace ConsoleTVs\Charts;

use Illuminate\Support\ServiceProvider;

class ChartsServiceProvider extends ServiceProvider
{
    public function register()
    {
        $this->app->singleton('charts', function ($app) {
            return new Charts();
        });
    }

    public function boot()
    {
        // Load views from the vendor directory if they exist
        $viewPath = resource_path('views/vendor/consoletvs/charts');
        if (file_exists($viewPath)) {
            $this->loadViewsFrom($viewPath, 'charts');
        }
    }
}
