=begin
#Lancer�̍s���m�����v���O����

��ʂ̃v���O��������A�G�̈ʒu��\�������l���^������
�\���́A0%,50%,100%��3�i�K(0~2)

�Ƃ肠��������3���厲�ɓ���
��̃`�����X0,1
	��̂���Ӗ����Ȃ��Ȃ�0
������0,1[x,y]
	�G�̍U���͈͂ɓ����Ă���
�U�߂�0,1[x,y]
	������܂łł͂Ȃ����A�ǂ��܂ōU�߂Ă悢��destance�Ō��߂�



##�����̎��͂𔻒�
�E��̏ꏊ�����������Ȃ�A��̊m���͒Ⴂ
�E�����悭��̂���ꏊ������΁A���̏ꏊ�̐�̂�D�悷��m��������
�E�G�ΐ��͂ɂ��ꂻ���Ȃ�A������m��������
�E�G�ΐ��͂�|�������Ȃ�A�߂Â��čU��������m��������
�E�߂��ʒu�Ŗ������͂��|���ꂻ���Ȃ�A�����ɍs���\��������
�E�\��1�̏ꏊ�����Ȃ��ꍇ�́A�߂��ɉB��čU���A������_���Ă���\���������̂Ōx�����s������m��������


##����
�E�X�^�[�g�㐼�������Ėk�ɐi�s�B�Z�C�o�[�̗̒n�ɓ��鎞�A���������܂ܓG�n�߂��ɐi�s�B�����߂��Ŗ\��܂��B


=end


#�Ƃ肠�����G�̎˒��ɓ���Ȃ��悤�ɍs��
#ally�����T�[�𒆐S��11*11��121�}�X�𑖍�
#HACK:����ł͔͈͊O�̓G�ɑ΂��鋗����Ԃ��Ȃ�(�S�����삷��ׂ����H)

class AskDestance
	#GetSet�̓A�N�Z�X���\�b�h�̒�`�ɂ��A�����I�ɐ錾����Ă���
	#���ꂼ�ꃉ���T�[�A�Z�C�o�[�A�o�[�T�[�J�[�ւ̋���
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

	#LSB�����ꂩ�̓G�}�b�v�A�����̍��W���󂯎���āAxy�̋�����z��ŕԂ�
	def EnemyDestance(enemyMap,enemyChar)
		destance=[]
		enemyPoint=[]

		for i in 0...15
			for j in 0...15
				next if enemyMap[i][j] == 0

				#�G�Ƃ̋������m�肵�Ă��邽�߁Areturn
				if enemyMap[i][j]==2
					enemyPoint[0]=j
					enemyPoint[1]=i

					destance[0]=j-@allyPoint[0]
					destance[1]=i-@allyPoint[1]
					break	#TODO:2�d���[�v����̒E�o
				end

				#HACK:�͈͂��傫�����Ăǂ������s�������ׂ������߂����˂Ă���
				if enemyMap[i][j]==1	#�ʒu������ł��Ȃ��̂œT�^�s���œh����҂�
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

	#�ʓ|������ꊇ�ŋ��������߂��Ⴄ��
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
		#�ȉ��̕ϐ��͂��ׂ�3�̗v�f���܂ށB�擪���珇��LSB�ł���B
		@@mode=["move","move","move"]	#kill,esc,stay,move�@��4�̃��[�h�ɂ���čs���𐧌䂷��B�擪����D��x�������B������kill�ɂ͗�O�L��
		@@moveDestance=[[0,0],[0,0],[0,0]]	#���݂̈ʒu���牽�}�X�ړ����邩�B�����̌��݈ʒu��0�Ƃ���B
		@@attackDivection=[1,1,1]	#�U������ꍇ�̕����B1���珇�Ԃɖk���쐼(���v���)�B
	end

	def KillRangeSearchL(allyPoint,enemyPointL,destanceL)
		#�E�C�J�n
		for i in enemyPointL[1]-4..enemyPointL[1]+4
			for j in enemyPointL[0]-4..enemyPointL[0]+4
				j+=3 if j==enemyPointL[0]-4 && i.abs>=2	#�����T�[�͈͊O���Ȃ�����
				break if j==enemyPointL[0]+2 && i.abs>=2	#����(�����T�[�͈͊O���Ȃ�����)

				#�����T�[�͈�(�\��������5�}�X�ڂɂ���4�_������)�ɓG�������ꍇ
				if allyPoint==[j,i]	#i==allyPoint[1] && j==allyPoint[0]
					if allyPoint==enemyPointL	#�����ʒu�ɂ��邽�߁A1�}�X�ړ����čU��
						@@moveDestance[0]=[1,0]
						@@attackDivection[0]=WEST
						@@mode[0]="kill"
						return
					end

					#0�����ˌ�����
					if i==enemyPointL[1]	#���U��
					 	@@moveDestance[0]=[0,0];@@attackDivection[0]=WEST if destance[0]<0
						@@moveDestance[0]=[0,0];@@attackDivection[0]=EAST if destance[0]>0
						@@mode[0]="kill"
						return
					end
					if j==enemyPointL[0]	#�c�U��
						@@moveDestance[0]=[0,0];@@attackDivection[0]=NORTH if destance[1]<0
						@@moveDestance[0]=[0,0];@@attackDivection[0]=SOUTH if destance[1]>0
						@@mode[0]="kill"
						return
					end

					#1�}�X�ړ��Ŏˌ�����
					if i==enemyPointL[1]-1 || i==enemyPointL[1]+1	#�c1�}�X�ړ��A���U��
						@@moveDestance[0]=[0,-1];@@attackDivection[0]=WEST if destance[1]<0&&destance[0]<0 #�k��
						@@moveDestance[0]=[0,1];@@attackDivection[0]=WEST if destance[1]>0&&destance[0]<0 #�쐼
						@@moveDestance[0]=[0,-1];@@attackDivection[0]=EAST if destance[1]<0&&destance[0]>0 #�k��
						@@moveDestance[0]=[0,1];@@attackDivection[0]=EAST if destance[1]>0&&destance[0]>0 #�쓌
						@@mode[0]="kill"
						return
					end
					if j==enemyPointL[0]-1 || j==enemyPointL[0]+1	#��1�}�X�ړ��A�c�U��
						@@moveDestance[0]=[-1,0];@@attackDivection[0]=NORTH if destance[1]<0&&destance[0]<0 #�k��
						@@moveDestance[0]=[-1,0];@@attackDivection[0]=SOUTH if destance[1]>0&&destance[0]<0 #�쐼
						@@moveDestance[0]=[1,0];@@attackDivection[0]=NORTH if destance[1]<0&&destance[0]>0 #�k��
						@@moveDestance[0]=[1,0];@@attackDivection[0]=SOUTH if destance[1]>0&&destance[0]>0 #�쓌
						@@mode[0]="kill"
						return
					end
				end
			end
		end#2�d���[�v�I���

		#�\���͈͂�5�}�X����Ă�����
		if enemyPointL[0]==allyPoint[0] && enemyPointL[1]+5==allyPoint[1] || enemyPointL[0]==allyPoint[0] && enemyPointL[1]-5==allyPoint[1]	#�c��1�}�X�ړ��A�E
			@@moveDestance[0]=[0,1];@@attackDivection[0]=SOUTH if destance[1]>0
			@@moveDestance[0]=[0,-1];@@attackDivection[0]=NORTH if destance[1]<0
			@@mode[0]="kill"
			return
		end
		if enemyPointL[1]==allyPoint[1]&&enemyPointL[0]+5==allyPoint[0] || enemyPointL[1]==allyPoint[1]&&enemyPointL[0]-5==allyPoint[0]	#����1�}�X�ړ��A�E
			@@moveDestance[0]=[1,0];@@attackDivection[0]=EAST if destance[0]>0
			@@moveDestance[0]=[-1,0];@@attackDivection[0]=WEST if destance[0]<0
			@@mode[0]="kill"
			return
		end

	end#KillRangeSearchL�I���

	#enemyL���E���邩
	#allyPoint=AskDestance�̃C���X�^���X.allyPoint
	#enemyPointL=AskDestance.enemyPointL
	def VersusL(allyPoint,enemyPointS,destanceS)
		#�G�̈ʒu���s���m�Ȃ̂ŁA���p�������ɂ߂ċ߂Â��U������
		if destance[0].abs==99
			#TODO:�T�^�^��

			@@mode[0]="move"
			return
		end

		#Kill����
		self.KillRangeSearchL(allyPoint,enemyPointL,destanceL)	#HACK:return��bool�l��Ԃ��悤�ɕύX�Btrue�Ȃ�return:

		#move����
		#�����T�[�͈͂̂��肬��őҋ@���ēG�̃~�X��҂���
		if allyPoint[0].abs==2 && allyPoint[1]>=-5 && allyPoint[1]<=5 || allyPoint[1].abs==2 && allyPoint[0]>=-5 && allyPoint[0]<=5 || \	# "#"�^�ɔ͈͂��i��(�c�A��)
			allyPoint[0].abs==2 && allyPoint[1].abs==5 || allyPoint[1].abs==2 && allyPoint[0].abs==5 || \	#�͈͂̓ʂ̌������Ƃ���(�c�A��)
			allyPoint[0]==0 && allyPoint[1].abs==6 || allyPoint[1]==0 && allyPoint[0].abs==6#�͈̓M���M���̓ʂ̐�[(�c�A��)
			@@moveDestance[0]=[0,0]
			@@mode="stay"
			return
		end

	end#VersusL�I���



	def VersusS(allyPoint,enemyPointS,destanceS)
		#�G�̈ʒu���s���m�Ȃ̂ŁA���p�������ɂ߂ċ߂Â��U������
		if destance[0].abs==99
			#TODO:�T�^�^��

			@@mode[0]="move"
			return
		end

		self.KillRangeSearchL(allyPoint,enemyPointS,destanceS)

		#for i in enemyPointS[1]-3..enemyPointS[1]+3
		#	for j in enemyPointS[0]-(3-i).abs..enemyPointS[0]+7-(3-i).abs	#1,3,5,7�񃋁[�v
		#	end
		#end
	end#VersusS�I���

	def VersusB(allyPoint,enemyPointB,destanceB)
		#�G�̈ʒu���s���m�Ȃ̂ŁA���p�������ɂ߂ċ߂Â��U������
		if destance[0].abs==99
			#TODO:�T�^�^��

			@@mode[0]="move"
			return
		end

		self.KillRangeSearchL(allyPoint,enemyPointB,destanceB)

	end#VersusB�I���


	def PriorityDecision
		@@mode	#�D��x���ɂǂ̃L������_�������߂�(kill,esc,stay,move
		@@moveDestance	#�ړ�����(�ړ�������݂̍��W�Ƃ̍��قŋ��߂Ă���)
		@@attackDivection	#�U������
	end#Priority�I���

end#def AttackOrStayL�I���
