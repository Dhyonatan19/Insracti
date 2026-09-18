import 'package:sqflite/sqflite.dart';
import 'package:primeiro_app/bancoDados/conect.dart';

class AuthService {

  static Future<int?> validarLogin(String email, String senha) async {
    try {
      Database db = await ConexaoSqflite.obterConexao();

      List<Map<String, dynamic>> resultados = await db.rawQuery(
        'SELECT ID FROM USUARIOS WHERE EMAIL = ? AND SENHA = ?',
        [email, senha],
      );

      if (resultados.isEmpty) return null;
      return resultados.first['ID'] as int;
    } catch (e) {
      print("Erro ao validar login no SQLite: $e");
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> listarUsuarios() async {
    try {
      Database db = await ConexaoSqflite.obterConexao();
      return await db.rawQuery('SELECT ID, NOME, EMAIL, FOTO FROM USUARIOS');
    } catch (e) {
      print("Erro ao listar usuários no SQLite: $e");
      return [];
    }
  }


  static Future<Map<String, dynamic>?> buscarUsuarioPorId(int id) async {
    try {
      Database db = await ConexaoSqflite.obterConexao();
      List<Map<String, dynamic>> resultado = await db.rawQuery(
        'SELECT ID, NOME, EMAIL, FOTO FROM USUARIOS WHERE ID = ?',
        [id],
      );
      if (resultado.isEmpty) return null;
      return resultado.first;
    } catch (e) {
      print("Erro ao buscar usuário: $e");
      return null;
    }
  }

  static Future<bool> cadastrarUsuario(
      String usu, String senha, String email, String foto) async {
    try {
      Database db = await ConexaoSqflite.obterConexao();

      int idGerado = await db.rawInsert(
        'INSERT INTO USUARIOS (NOME, SENHA, EMAIL, FOTO) VALUES (?, ?, ?, ?)',
        [usu, senha, email, foto],
      );

      print("Usuário cadastrado no SQLite com ID: $idGerado");
      return idGerado > 0;
    } catch (e) {
      print("Erro ao cadastrar no SQLite: $e");
      return false;
    }
  }

  static Future<bool> atualizarNome(int id, String novoNome) async {
    try {
      Database db = await ConexaoSqflite.obterConexao();
      int linhas = await db.rawUpdate(
        'UPDATE USUARIOS SET NOME = ? WHERE ID = ?',
        [novoNome, id],
      );
      return linhas > 0;
    } catch (e) {
      print("Erro ao atualizar nome: $e");
      return false;
    }
  }

  static Future<bool> atualizarEmail(int id, String novoEmail) async {
    try {
      Database db = await ConexaoSqflite.obterConexao();
      int linhas = await db.rawUpdate(
        'UPDATE USUARIOS SET EMAIL = ? WHERE ID = ?',
        [novoEmail, id],
      );
      return linhas > 0;
    } catch (e) {
      print("Erro ao atualizar email: $e");
      return false;
    }
  }


  static Future<bool> atualizarFoto(int id, String novaFoto) async {
    try {
      Database db = await ConexaoSqflite.obterConexao();
      int linhas = await db.rawUpdate(
        'UPDATE USUARIOS SET FOTO = ? WHERE ID = ?',
        [novaFoto, id],
      );
      return linhas > 0;
    } catch (e) {
      print("Erro ao atualizar foto: $e");
      return false;
    }
  }

  static Future<void> listarMensagens() async {
    try {
      Database db = await ConexaoSqflite.obterConexao();

      List<Map<String, dynamic>> mensagens =
      await db.rawQuery('SELECT * FROM MENSAGENS');

      print(" MENSAGENS NO BANCO ---");
      for (var m in mensagens) {
        print(
            "ID: ${m['ID']} | De: ${m['DE']} -> Para: ${m['PARA']} | Conteúdo: ${m['CONTEUDO']} | Horário: ${m['HORARIO']}");
      }
      print("----------------------------");
    } catch (e) {
      print("Erro ao ler mensagens: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> buscarMensagens(
      int meuId, int outroId) async {
    try {
      Database db = await ConexaoSqflite.obterConexao();
      return await db.rawQuery('''
      SELECT * FROM MENSAGENS 
      WHERE (DE = ? AND PARA = ?) OR (DE = ? AND PARA = ?)
      ORDER BY ID ASC
    ''', [meuId, outroId, outroId, meuId]);
    } catch (e) {
      print("Erro ao buscar mensagens: $e");
      return [];
    }
  }

  static Future<bool> cadastrarMensagem(
      String conteudo, int deId, int paraId, {String? foto}) async {
    try {
      Database db = await ConexaoSqflite.obterConexao();
      int id = await db.rawInsert(
        'INSERT INTO MENSAGENS (CONTEUDO, FOTO, DE, PARA, ESTADO) VALUES (?, ?, ?, ?, ?)',
        [
          conteudo.isEmpty ? null : conteudo,
          foto,
          deId,
          paraId,
          'ENVIADO MAS NÃO VISTO',
        ],
      );
      return id > 0;
    } catch (e) {
      print("Erro ao enviar mensagem: $e");
      return false;
    }
  }


  static Future<void> marcarComoVisto(int meuId, int outroId) async {
    try {
      Database db = await ConexaoSqflite.obterConexao();
      await db.rawUpdate(
        '''
        UPDATE MENSAGENS 
        SET ESTADO = 'VISTO' 
        WHERE DE = ? AND PARA = ? AND ESTADO != 'VISTO'
        ''',
        [outroId, meuId],
      );
    } catch (e) {
      print("Erro ao marcar mensagens como vistas: $e");
    }
  }

  static Future<bool> atualizarSenha(String email, String novaSenha) async {
    try {
      Database db = await ConexaoSqflite.obterConexao();

      int quantidadeLinhasAfetadas = await db.rawUpdate(
        'UPDATE USUARIOS SET SENHA = ? WHERE EMAIL = ?',
        [novaSenha, email],
      );

      return quantidadeLinhasAfetadas > 0;
    } catch (e) {
      print("Erro ao redefinir a senha: $e");
      return false;
    }
  }
}