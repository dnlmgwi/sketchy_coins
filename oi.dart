public boolean isFirstBlockValid() {
    Block firstBlock = blocks.get(0);

    if (firstBlock.getIndex() != 0) {
      return false;
    }

    if (firstBlock.getPreviousHash() != null) {
      return false;
    }

    if (firstBlock.getHash() == null || 
          !Block.calculateHash(firstBlock).equals(firstBlock.getHash())) {
      return false;
    }

    return true;
  }

  public boolean isValidNewBlock(Block newBlock, Block previousBlock) {
    if (newBlock != null  &&  previousBlock != null) {
      if (previousBlock.getIndex() + 1 != newBlock.getIndex()) {
        return false;
      }

      if (newBlock.getPreviousHash() == null  ||  
	    !newBlock.getPreviousHash().equals(previousBlock.getHash())) {
        return false;
      }

      if (newBlock.getHash() == null  ||  
	    !Block.calculateHash(newBlock).equals(newBlock.getHash())) {
        return false;
      }

      return true;
    }

    return false;
  }

  public boolean isBlockChainValid() {
    if (!isFirstBlockValid()) {
      return false;
    }

    for (int i = 1; i < blocks.size(); i++) {
      Block currentBlock = blocks.get(i);
      Block previousBlock = blocks.get(i - 1);

      if (!isValidNewBlock(currentBlock, previousBlock)) {
        return false;
      }
    }

    return true;
  }

