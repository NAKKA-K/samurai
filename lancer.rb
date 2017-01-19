=begin
#Lancerの行動確率をプログラム

上位のプログラムから、敵の位置を予測した値が与えられる
予測は、0%,50%,100%の3段階(0~2)

とりあえずこの3つを主軸に動く
占領チャンス0,1
	占領する意味がないなら0
逃げる0,1[x,y]
	敵の攻撃範囲に入っている
攻める0,1[x,y]
	逃げるまでではないが、どこまで攻めてよいかdestanceで決める



##自分の周囲を判定
・占領場所が無さそうなら、占領確率は低い
・効率よく占領する場所があれば、その場所の占領を優先する確率が高い
・敵対勢力にやられそうなら、逃げる確率が高い
・敵対勢力を倒せそうなら、近づいて攻撃をする確率が高い
・近い位置で味方勢力が倒されそうなら、助けに行く可能性が高い
・予測1の場所しかない場合は、近くに隠れて攻撃、逃げを狙っている可能性が高いので警戒しつつ行動する確率が高い


##メモ
・スタート後西を向いて北に進行。セイバーの領地に入る時、潜伏したまま敵地近くに進行。中央近くで暴れまわる。


=end


#とりあえず敵の射程に入らないように行動
#allyランサーを中心に11*11の121マスを走査
#HACK:これでは範囲外の敵に対する距離を返せない(全部操作するべきか？)

class AskDestance
	#GetSetはアクセスメソッドの定義により、自動的に宣言されている
	#それぞれランサー、セイバー、バーサーカーへの距離
	attr_accessor :destanceL, :destanceS, :destanceB, :allyPoint
	attr_reader :enemyPointL, :enemyPointS, :enemyPointB

	def Initialize
		@allyPoint=[99,99]

		@@enemyPointL=[99,99]
		@destanceL=[99,99]

		@@enemyPointS=[99,99]
		@destanceS=[99,99]

		@@enemyPointB=[99,99]
		@destanceB=[99,99]
	end

	#LSBいずれかの敵マップ、自分の座標を受け取って、xyの距離を配列で返す
	def EnemyDestance(enemyMap,enemyChar)
		destance=[]
		enemyPoint=[]

		for i in 0...15
			for j in 0...15
				next if enemyMap[i][j] == 0

				#敵との距離が確定しているため、return
				if enemyMap[i][j]==2
					enemyPoint[0]=j
					enemyPoint[1]=i

					destance[0]=j-@allyPoint[0]
					destance[1]=i-@allyPoint[1]
					break	#TODO:2重ループからの脱出
				end

				#HACK:範囲が大きすぎてどういう行動をすべきか決めあぐねている
				if enemyMap[i][j]==1	#位置が特定できないので典型行動で塗りを稼ぐ
					destance=[99,99]
					enemyPoint=[99,99]
					#destance[0]=-99 if (j-@allyPoint[0])<0
					#destance[1]=-99 if (i-@allyPoint[1])<0
					#destance[0]=99 if (j-@allyPoint[0])>0
					#destance[1]=99 if (i-@allyPoint[1])>0
				end

			end
		end

		case enemyChar
		when "L"
			@enemyPointL=enemyPoint
			@destanceL=destance
		when "S"
			@enemyPointS=enemyPoint
			@destanceS=destance
		when "B"
			@enemyPointB=enemyPoint
			@destanceB=destance
		end
	end

	#面倒だから一括で距離を求めちゃうぞ
	def AllEnemyDestance(enemyMapL,enemyMapS,enemyMapB,allyPoint)
		@allyPoint=allyPoint
		self.EnemyDestance(enemyMapL,"L")
		self.EnemyDestance(enemyMapS,"S")
		self.EnemyDestance(enemyMapB,"B")
	end
end


class AttackOrStayL
	NORTH=1
	EAST=2
	SOUTH=3
	WEST=4

	def Initialize
		#以下の変数はすべて3つの要素を含む。先頭から順にLSBである。
		@@mode=["move","move","move"]	#kill,esc,stay,move　の4つのモードによって行動を制御する。先頭から優先度が高い。ただしkillには例外有り
		@@moveDestance=[[0,0],[0,0],[0,0]]	#現在の位置から何マス移動するか。自分の現在位置を0とする。
		@@attackDivection=[1,1,1]	#攻撃する場合の方向。1から順番に北東南西(時計回り)。
	end

	def KillRangeSearchL(allyPoint,enemyPointL,destanceL)
		#殺戮開始
		for i in enemyPointL[1]-4..enemyPointL[1]+4
			for j in enemyPointL[0]-4..enemyPointL[0]+4
				j+=3 if j==enemyPointL[0]-4 && i.abs>=2	#ランサー範囲外を省く処理
				break if j==enemyPointL[0]+2 && i.abs>=2	#同上(ランサー範囲外を省く処理)

				#ランサー範囲(十字方向の5マス目にある4点を除く)に敵がいた場合
				if allyPoint==[j,i]	#i==allyPoint[1] && j==allyPoint[0]
					if allyPoint==enemyPointL	#同じ位置にいるため、1マス移動して攻撃
						@@moveDestance[0]=[1,0]
						@@attackDivection[0]=WEST
						@@mode[0]="kill"
						return
					end

					#0距離射撃圏内
					if i==enemyPointL[1]	#横攻撃
					 	@@moveDestance[0]=[0,0];@@attackDivection[0]=WEST if destance[0]<0
						@@moveDestance[0]=[0,0];@@attackDivection[0]=EAST if destance[0]>0
						@@mode[0]="kill"
						return
					end
					if j==enemyPointL[0]	#縦攻撃
						@@moveDestance[0]=[0,0];@@attackDivection[0]=NORTH if destance[1]<0
						@@moveDestance[0]=[0,0];@@attackDivection[0]=SOUTH if destance[1]>0
						@@mode[0]="kill"
						return
					end

					#1マス移動で射撃圏内
					if i==enemyPointL[1]-1 || i==enemyPointL[1]+1	#縦1マス移動、横攻撃
						@@moveDestance[0]=[0,-1];@@attackDivection[0]=WEST if destance[1]<0&&destance[0]<0 #北西
						@@moveDestance[0]=[0,1];@@attackDivection[0]=WEST if destance[1]>0&&destance[0]<0 #南西
						@@moveDestance[0]=[0,-1];@@attackDivection[0]=EAST if destance[1]<0&&destance[0]>0 #北東
						@@moveDestance[0]=[0,1];@@attackDivection[0]=EAST if destance[1]>0&&destance[0]>0 #南東
						@@mode[0]="kill"
						return
					end
					if j==enemyPointL[0]-1 || j==enemyPointL[0]+1	#横1マス移動、縦攻撃
						@@moveDestance[0]=[-1,0];@@attackDivection[0]=NORTH if destance[1]<0&&destance[0]<0 #北西
						@@moveDestance[0]=[-1,0];@@attackDivection[0]=SOUTH if destance[1]>0&&destance[0]<0 #南西
						@@moveDestance[0]=[1,0];@@attackDivection[0]=NORTH if destance[1]<0&&destance[0]>0 #北東
						@@moveDestance[0]=[1,0];@@attackDivection[0]=SOUTH if destance[1]>0&&destance[0]>0 #南東
						@@mode[0]="kill"
						return
					end
				end
			end
		end#2重ループ終わり

		#十字範囲で5マス離れている状態
		if enemyPointL[0]==allyPoint[0] && enemyPointL[1]+5==allyPoint[1] || enemyPointL[0]==allyPoint[0] && enemyPointL[1]-5==allyPoint[1]	#縦に1マス移動、殺
			@@moveDestance[0]=[0,1];@@attackDivection[0]=SOUTH if destance[1]>0
			@@moveDestance[0]=[0,-1];@@attackDivection[0]=NORTH if destance[1]<0
			@@mode[0]="kill"
			return
		end
		if enemyPointL[1]==allyPoint[1]&&enemyPointL[0]+5==allyPoint[0] || enemyPointL[1]==allyPoint[1]&&enemyPointL[0]-5==allyPoint[0]	#横に1マス移動、殺
			@@moveDestance[0]=[1,0];@@attackDivection[0]=EAST if destance[0]>0
			@@moveDestance[0]=[-1,0];@@attackDivection[0]=WEST if destance[0]<0
			@@mode[0]="kill"
			return
		end

	end#KillRangeSearchL終わり

	#enemyLを殺せるか
	#allyPoint=AskDestanceのインスタンス.allyPoint
	#enemyPointL=AskDestance.enemyPointL
	def VersusL(allyPoint,enemyPointS,destanceS)
		#敵の位置が不明確なので、方角だけ見極めて近づきつつ攻撃する
		if destance[0].abs==99
			#TODO:典型運動

			@@mode[0]="move"
			return
		end

		#Kill判定
		self.KillRangeSearchL(allyPoint,enemyPointL,destanceL)	#HACK:returnでbool値を返すように変更。trueならreturn:

		#move判定
		#ランサー範囲のぎりぎりで待機して敵のミスを待つ処理
		if allyPoint[0].abs==2 && allyPoint[1]>=-5 && allyPoint[1]<=5 || allyPoint[1].abs==2 && allyPoint[0]>=-5 && allyPoint[0]<=5 || \	# "#"型に範囲を絞る(縦、横)
			allyPoint[0].abs==2 && allyPoint[1].abs==5 || allyPoint[1].abs==2 && allyPoint[0].abs==5 || \	#範囲の凸の欠けたところ(縦、横)
			allyPoint[0]==0 && allyPoint[1].abs==6 || allyPoint[1]==0 && allyPoint[0].abs==6#範囲ギリギリの凸の先端(縦、横)
			@@moveDestance[0]=[0,0]
			@@mode="stay"
			return
		end

	end#VersusL終わり



	def VersusS(allyPoint,enemyPointS,destanceS)
		#敵の位置が不明確なので、方角だけ見極めて近づきつつ攻撃する
		if destance[0].abs==99
			#TODO:典型運動

			@@mode[0]="move"
			return
		end

		self.KillRangeSearchL(allyPoint,enemyPointS,destanceS)

		#for i in enemyPointS[1]-3..enemyPointS[1]+3
		#	for j in enemyPointS[0]-(3-i).abs..enemyPointS[0]+7-(3-i).abs	#1,3,5,7回ループ
		#	end
		#end
	end#VersusS終わり

	def VersusB(allyPoint,enemyPointB,destanceB)
		#敵の位置が不明確なので、方角だけ見極めて近づきつつ攻撃する
		if destance[0].abs==99
			#TODO:典型運動

			@@mode[0]="move"
			return
		end

		self.KillRangeSearchL(allyPoint,enemyPointB,destanceB)

	end#VersusB終わり


	def PriorityDecision
		@@mode	#優先度順にどのキャラを狙うか決める(kill,esc,stay,move
		@@moveDestance	#移動距離(移動先を現在の座標との差異で求めている)
		@@attackDivection	#攻撃方向
	end#Priority終わり

end#def AttackOrStayL終わり
