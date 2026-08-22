import 'package:dating/Logic/cubits/match_cubit/match_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

bool errorloader = false;

class MatchProvider extends ChangeNotifier {
  List menuData = ["New Match", "Like Me", "Favourite", "Passed"];

  int selectIndex = 0;

  updateIndex(int index) {
    selectIndex = index;
    notifyListeners();
  }

  matchInit(context) {
    MatchCubit matchCubit = BlocProvider.of<MatchCubit>(context, listen: false);
    matchCubit.loadingState();
    matchCubit.newMatchApi(context).then((newMatchApi) {
      matchCubit.favouriteApi(context).then((favoriteApi) {
        print("6767676767676767 matchInit");
        matchCubit.passedApi(context).then((passedApi) {
          print("909090909090909090 matchInit");
          matchCubit.likeMeApi(context).then((likeApi) {
            matchCubit.completeState(passedApi, likeApi, newMatchApi, favoriteApi);
            notifyListeners();
          });
        });
      });
    });
  }

  callAllApi(context){
      MatchCubit matchCubit = BlocProvider.of<MatchCubit>(context, listen: false);
      errorloader = true;
      matchCubit.newMatchApi(context).then((newMatchApi) {
        print("datadataydatafgfcvhjsvhgsv${errorloader}");
        matchCubit.favouriteApi(context).then((favoriteApi) {
          print("6767676767676767 callAllApi${errorloader}");
          matchCubit.passedApi(context).then((passedApi) {
            print("909090909090909090 callAllApi${errorloader}");
            errorloader = false;
            print("errrrrrrrrrrrrrrrrrrrrrrrrrrrr ${errorloader}");
            matchCubit.likeMeApi(context).then((likeApi) {
              matchCubit.completeState(passedApi, likeApi, newMatchApi, favoriteApi);
              notifyListeners();
            });
          });
        });
      });
  }


}
