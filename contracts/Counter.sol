// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;


contract Counter {
  uint public x;
  uint public max;
  uint public min;

  constructor(){
    min = type(uint256).max;
    max = 0;
  }

  event Increment(uint by);

  function inc() public {
    x++;
    
   _updateMinMax();

    emit Increment(1);
  }

  function _updateMinMax() internal {
    if(x > max){
      max = x;
    }
    if(x < min){
      min = x;
    }
  }

  function incBy(uint by) public {
    require(by > 0, "incBy: increment should be positive");
    x += by;
    _updateMinMax();
    emit Increment(by);
  }

  function double() public {
    x*=2;
    _updateMinMax();
  }

  function isEven() external view returns (bool) {
      return (x % 2 == 0);  
  }

}
