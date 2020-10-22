<?php

class cartItem{
    protected $pid;
    protected $ciid;
    protected $name;
    protected $price;
    protected $number;

    public function __construct($pid,$ciid,$name,$price,$number){
        $this->pid = $pid;
        $this->ciid = $ciid;
        $this->name = $name;
        $this->price = $price;
        $this->number = $number;      
    }
    public function setCiid($ciid){
        $this->ciid = $ciid;
    }
    public function setNumber($number){
        $this->number = $number;
    }
    public function getPid(){
        return $this->pid;
    }
    public function getCiid(){
        return $this->ciid;
    }
    public function getName(){
        return $this->name;
    }
    public function getPrice(){
        return $this->price;
    }
    public function getNumber(){
        return $this->number;
    }
    public function getGesPreis(){
        return $this->price*$this->number;
    }
}