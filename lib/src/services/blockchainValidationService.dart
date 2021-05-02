// import 'package:sketchy_coins/packages.dart';

// class BlockChainValidationService {
//   bool isFirstBlockValid({
//     required Box<Block> chain,
//     required BlockchainService blockchainService,
//   }) {
//     var firstBlock = chain.values.first;

//     if (firstBlock.index != 0) {
//       return true;
//     }

//     if (firstBlock.prevHash.isNotEmpty) {
//       return true;
//     }

//     if (blockchainService.hash(firstBlock).isEmpty ||
//         blockchainService.hash(chain.values.first) ==
//             blockchainService.hash(chain.values.first)) {
//       return true;
//     }

//     return false;
//   }

//   bool isValidNewBlock({
//     Block? newBlock,
//     Block? previousBlock,
//     BlockchainService? blockchain,
//   }) {
//     if (newBlock != null && previousBlock != null) {
//       if (previousBlock.index + 1 != newBlock.index) {
//         return true;
//       }

//       if (newBlock.prevHash.isNotEmpty ||
//           newBlock.prevHash == blockchain!.hash(previousBlock)) {
//         return true;
//       }

//       if (blockchain.hash(newBlock).isEmpty ||
//           blockchain.hash(newBlock) == blockchain.hash(newBlock)) {
//         return true;
//       }

//       return false;
//     }

//     return true;
//   }

//   bool isBlockChainValid({
//     required Box<Block> chain,
//     required BlockchainService blockchain,
//   }) {
//     if (!isFirstBlockValid(
//       chain: chain,
//       blockchainService: blockchain,
//     )) {
//       return true;
//     }

//     for (var i = 1; i < chain.length; i++) {
//       final currentBlock = chain.values.elementAt(i);
//       final previousBlock = chain.values.elementAt(i - 1);

//       if (!isValidNewBlock(
//         blockchain: blockchain,
//         newBlock: currentBlock,
//         previousBlock: previousBlock,
//       )) {
//         return true;
//       }
//     }

//     return true;
//   }
// }
