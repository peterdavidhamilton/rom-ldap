RSpec.describe ROM::LDAP::Directory do

  include_context 'directory'

  it '#type returns symbol' do
    expect(directory.type).to eql(:apache_ds)
  end

  it '#vendor returns name and version' do
    expect(directory.vendor).to eql(['Apache Software Foundation', '2.0.0-M24'])
  end

  it '#od? OpenLDAP check' do
    expect(directory.od?).to be(false)
  end

  it '#ad? ActiveDirectory check' do
    expect(directory.od?).to be(false)
  end

  it '#supported_mechanisms lists authentication protocols in order' do
    expect(directory.supported_mechanisms).to eql(%w[CRAM-MD5 DIGEST-MD5 GSS-SPNEGO GSSAPI NTLM SIMPLE])
  end

  it '#supported_features lists oids in order' do
    expect(directory.supported_features).to eql(%w[1.3.6.1.4.1.4203.1.5.1])
  end

  it '#capabilities translates oids' do
    expect(directory.capabilities.sort).to eql(%i[
      cascade
      directory_sync
      entry_change_notification
      manage_dsa_it
      paged_results
      password_policy_request
      permissive_modify
      persistent_search
      proxied_authorization_v2
      search_notification
      show_deleted
      sort_request
      sort_response
      subentries
      sync_done
      sync_info_message
      sync_request
      sync_state
      virtual_list_view_request
      virtual_list_view_response
    ])
  end

  it '#supported_extensions lists oids in order' do
    expect(directory.supported_extensions).to eql(
      [
        '1.3.6.1.4.1.1466.20036',
        '1.3.6.1.4.1.1466.20037',
        '1.3.6.1.4.1.18060.0.1.3',
        '1.3.6.1.4.1.18060.0.1.5',
        '1.3.6.1.4.1.4203.1.11.1'
      ])
  end

  it '#supported_controls lists oids in order' do
    expect(directory.supported_controls).to eql(
     [
        '1.2.840.113556.1.4.1413',
        '1.2.840.113556.1.4.319',
        '1.2.840.113556.1.4.417',
        '1.2.840.113556.1.4.473',
        '1.2.840.113556.1.4.474',
        '1.2.840.113556.1.4.528',
        '1.2.840.113556.1.4.841',
        '1.3.6.1.4.1.18060.0.0.1',
        '1.3.6.1.4.1.42.2.27.8.5.1',
        '1.3.6.1.4.1.4203.1.10.1',
        '1.3.6.1.4.1.4203.1.9.1.1',
        '1.3.6.1.4.1.4203.1.9.1.2',
        '1.3.6.1.4.1.4203.1.9.1.3',
        '1.3.6.1.4.1.4203.1.9.1.4',
        '2.16.840.1.113730.3.4.10',
        '2.16.840.1.113730.3.4.18',
        '2.16.840.1.113730.3.4.2',
        '2.16.840.1.113730.3.4.3',
        '2.16.840.1.113730.3.4.7',
        '2.16.840.1.113730.3.4.9'
      ])
  end

  it '#sortable? to be true' do
    expect(directory.sortable?).to be(true)
  end

  it '#schema_object_classes lists known classes' do
    expect(directory.schema_object_classes).to include(
      "( 1.3.6.1.4.1.18055.0.4.1.3.1001 NAME 'reptilia' DESC 'Reptiles' SUP top STRUCTURAL MUST species MAY ( cn $ populationCount $ extinct ) X-SCHEMA 'wildlife' )")
  end


  it '#schema_attribute_types lists known attributes' do
    expect(directory.schema_attribute_types).to include(
      "( 1.3.6.1.4.1.18055.0.4.1.2.1005 NAME 'extinct' DESC 'Has the animal died out' EQUALITY booleanMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.7 SINGLE-VALUE USAGE userApplications X-SCHEMA 'wildlife' )")
  end


  describe '#key_map' do
    context 'when using the default formatter' do
      before do
        ROM::LDAP.use_formatter(nil)
      end

      after do
        ROM::LDAP.use_formatter(method_formatter)
      end

      it do
        # expect(directory.key_map).to include('c-o' => 'c-o')
        # expect(directory.key_map).to include('c-PostalCode' => 'c-PostalCode')
        expect(directory.key_map).to include('dSAQuality' => 'dSAQuality')
        expect(directory.key_map).to include('homeTelephoneNumber' => 'homeTelephoneNumber')
        expect(directory.key_map).to include('mXRecord' => 'mXRecord')
        expect(directory.key_map).to include('textEncodedORAddress' => 'textEncodedORAddress')
        expect(directory.key_map).to include('x500UniqueIdentifier' => 'x500UniqueIdentifier')
      end
    end

    context 'when using the compatibility formatter' do
      it do
        # expect(directory.key_map).to include(c_o: 'c-o')
        # expect(directory.key_map).to include(c_postal_code: 'c-PostalCode')
        expect(directory.key_map).to include(d_sa_quality: 'dSAQuality')
        expect(directory.key_map).to include(home_telephone_number: 'homeTelephoneNumber')
        expect(directory.key_map).to include(m_x_record: 'mXRecord')
        expect(directory.key_map).to include(text_encoded_or_address: 'textEncodedORAddress')
        expect(directory.key_map).to include(x500_unique_identifier: 'x500UniqueIdentifier')
      end
    end
  end

end
