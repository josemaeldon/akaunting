<?php

namespace ConsoleTVs\Charts;

class ChartBuilder
{
    protected $type;
    protected $library;
    protected $colors = [];
    protected $labels = [];
    protected $values = [];
    protected $dimensions = [0, 300];
    protected $credits = true;
    protected $view;

    public function __construct($type, $library)
    {
        $this->type = $type;
        $this->library = $library;
    }

    public function colors($colors)
    {
        $this->colors = is_array($colors) ? $colors : func_get_args();
        return $this;
    }

    public function labels($labels)
    {
        $this->labels = $labels;
        return $this;
    }

    public function values($values)
    {
        $this->values = $values;
        return $this;
    }

    public function dimensions($width, $height)
    {
        $this->dimensions = [$width, $height];
        return $this;
    }

    public function credits($credits)
    {
        $this->credits = $credits;
        return $this;
    }

    public function view($view)
    {
        $this->view = $view;
        return $this;
    }

    public function render()
    {
        return view($this->view, [
            'type' => $this->type,
            'library' => $this->library,
            'colors' => $this->colors,
            'labels' => $this->labels,
            'values' => $this->values,
            'dimensions' => $this->dimensions,
            'credits' => $this->credits,
        ]);
    }

    public function __toString()
    {
        return (string) $this->render();
    }
}
